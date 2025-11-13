use std::{borrow::Cow, fmt};

use serde::{ser, Serialize};

type Result<T> = std::result::Result<T, LuaSerializerError>;

/// Convert serializable data into a Lua Expression
pub(crate) fn to_expression<T>(value: &T) -> Result<Expression>
where
    T: Serialize,
{
    let mut serializer = Serializer {
        output: Expression::nil(),
        operation: Vec::new(),
        expression_stack: Vec::new(),
    };
    value.serialize(&mut serializer)?;
    Ok(serializer.output)
}

#[derive(Debug)]
pub(crate) struct LuaSerializerError {
    message: Cow<'static, str>,
    is_internal: bool,
}

impl LuaSerializerError {
    pub(crate) fn new(message: impl Into<Cow<'static, str>>) -> Self {
        Self {
            message: message.into(),
            is_internal: false,
        }
    }

    pub(crate) fn internal(message: impl Into<Cow<'static, str>>) -> Self {
        Self {
            message: message.into(),
            is_internal: true,
        }
    }
}

impl ser::Error for LuaSerializerError {
    fn custom<T: fmt::Display>(msg: T) -> Self {
        LuaSerializerError::new(msg.to_string())
    }
}

impl fmt::Display for LuaSerializerError {
    fn fmt(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
        if self.is_internal {
            formatter.write_str(&self.message)
        } else {
            write!(formatter, "{} [internal]", self.message)
        }
    }
}

impl std::error::Error for LuaSerializerError {}

use crate::{
    nodes::{
        DecimalNumber, Expression, FieldExpression, FunctionCall, HexNumber, Identifier,
        StringExpression, TableEntry, TableExpression, TableFieldEntry, TableIndexEntry,
        TupleArguments,
    },
    process::utils::is_valid_identifier,
};

enum SerializeOperation {
    Table(Vec<TableEntry>),
    TableEntryKey,
    TableEntryValue,
}

struct Serializer {
    output: Expression,
    operation: Vec<SerializeOperation>,
    expression_stack: Vec<Expression>,
}

impl Serializer {
    fn process(&mut self, expression: Expression) -> Result<()> {
        if let Some(mut operation) = self.operation.pop() {
            let keep = match &mut operation {
                SerializeOperation::Table(entries) => {
                    entries.push(TableEntry::from_value(expression));
                    true
                }
                SerializeOperation::TableEntryKey => {
                    self.expression_stack.push(expression);
                    false
                }
                SerializeOperation::TableEntryValue => {
                    self.complete_table_entry(expression)?;
                    false
                }
            };

            if keep {
                self.operation.push(operation);
            }
        } else {
            self.output = expression;
        }
        Ok(())
    }

    // this method is used once a key expression has been pushed to the stack
    // and the next expression is the value associated with the key to be pushed
    // into a table
    fn complete_table_entry(&mut self, entry_value: Expression) -> Result<()> {
        let key = self.expression_stack.pop().ok_or_else(|| {
            LuaSerializerError::internal("key expression expected to build table expression")
        })?;

        if let Some(last_operation) = self.operation.last_mut() {
            match last_operation {
                SerializeOperation::Table(entries) => {
                    if let Expression::String(string) = key {
                        if let Some(value) = string
                            .get_string_value()
                            .filter(|value| is_valid_identifier(value))
                        {
                            entries
                                .push(TableFieldEntry::new(value.to_owned(), entry_value).into());
                        } else {
                            entries.push(TableIndexEntry::new(string, entry_value).into());
                        }
                    } else {
                        entries.push(TableIndexEntry::new(key, entry_value).into());
                    }
                    Ok(())
                }
                SerializeOperation::TableEntryKey => Err(LuaSerializerError::internal(
                    "unable to push key-value pair with a table key operation",
                )),
                SerializeOperation::TableEntryValue => Err(LuaSerializerError::internal(
                    "unable to push key-value pair with a table value operation",
                )),
            }
        } else {
            Err(LuaSerializerError::internal(
                "missing table operation to push key-value pair",
            ))
        }
    }

    fn begin_table(&mut self, len: Option<usize>) {
        let mut sequence = Vec::<TableEntry>::new();
        if let Some(len) = len {
            sequence.reserve_exact(len);
        }
        self.operation.push(SerializeOperation::Table(sequence));
    }

    fn close_table(&mut self) -> Result<()> {
        if let Some(operation) = self.operation.pop() {
            match operation {
                SerializeOperation::Table(entries) => {
                    self.process(TableExpression::new(entries).into())
                }
                SerializeOperation::TableEntryValue => Err(LuaSerializerError::internal(
                    "unable to complete table with a table value operation",
                )),
                SerializeOperation::TableEntryKey => Err(LuaSerializerError::internal(
                    "unable to complete table with a table key operation",
                )),
            }
        } else {
            Err(LuaSerializerError::internal(
                "missing table operation to complete table expression",
            ))
        }
    }

    fn begin_table_entry_key(&mut self) {
        self.operation.push(SerializeOperation::TableEntryKey);
    }

    fn begin_table_entry_value(&mut self) {
        self.operation.push(SerializeOperation::TableEntryValue);
    }
}

impl ser::Serializer for &mut Serializer {
    // The output type produced by this `Serializer` during successful
    // serialization. Most serializers that produce text or binary output should
    // set `Ok = ()` and serialize into an `io::Write` or buffer contained
    // within the `Serializer` instance, as happens here. Serializers that build
    // in-memory data structures may be simplified by using `Ok` to propagate
    // the data structure around.
    type Ok = ();

    // The error type when some error occurs during serialization.
    type Error = LuaSerializerError;

    // Associated types for keeping track of additional state while serializing
    // compound data structures like sequences and maps. In this case no
    // additional state is required beyond what is already stored in the
    // Serializer struct.
    type SerializeSeq = Self;
    type SerializeTuple = Self;
    type SerializeTupleStruct = Self;
    type SerializeTupleVariant = Self;
    type SerializeMap = Self;
    type SerializeStruct = Self;
    type SerializeStructVariant = Self;

    fn serialize_bool(self, v: bool) -> Result<()> {
        self.process(v.into())
    }

    fn serialize_i8(self, v: i8) -> Result<()> {
        self.serialize_i64(i64::from(v))
    }

    fn serialize_i16(self, v: i16) -> Result<()> {
        self.serialize_i64(i64::from(v))
    }

    fn serialize_i32(self, v: i32) -> Result<()> {
        self.serialize_i64(i64::from(v))
    }

    fn serialize_i64(self, v: i64) -> Result<()> {
        self.process(DecimalNumber::new(v as f64).into())
    }

    fn serialize_u8(self, v: u8) -> Result<()> {
        self.serialize_u64(u64::from(v))
    }

    fn serialize_u16(self, v: u16) -> Result<()> {
        self.serialize_u64(u64::from(v))
    }

    fn serialize_u32(self, v: u32) -> Result<()> {
        self.serialize_u64(u64::from(v))
    }

    fn serialize_u64(self, v: u64) -> Result<()> {
        self.process(DecimalNumber::new(v as f64).into())
    }

    fn serialize_f32(self, v: f32) -> Result<()> {
        self.serialize_f64(f64::from(v))
    }

    fn serialize_f64(self, v: f64) -> Result<()> {
        self.process(DecimalNumber::new(v).into())
    }

    fn serialize_char(self, v: char) -> Result<()> {
        self.serialize_str(&v.to_string())
    }

    fn serialize_str(self, v: &str) -> Result<()> {
        self.process(StringExpression::from_value(v).into())
    }

    // Serialize a byte array as an array of bytes. Could also use a base64
    // string here. Binary formats will typically represent byte arrays more
    // compactly.
    fn serialize_bytes(self, v: &[u8]) -> Result<()> {
        let arguments = v.iter().fold(TupleArguments::default(), |arguments, byte| {
            arguments.with_argument(HexNumber::new(*byte as u64, false))
        });
        self.process(
            FunctionCall::new(
                FieldExpression::new(Identifier::new("string"), "char").into(),
                arguments.into(),
                None,
            )
            .into(),
        )
    }

    fn serialize_none(self) -> Result<()> {
        self.process(Expression::nil())
    }

    fn serialize_some<T>(self, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        value.serialize(self)
    }

    // In Serde, unit means an anonymous value containing no data.
    fn serialize_unit(self) -> Result<()> {
        self.process(Expression::nil())
    }

    // Unit struct means a named value containing no data.
    fn serialize_unit_struct(self, _name: &'static str) -> Result<()> {
        self.serialize_unit()
    }

    // When serializing a unit variant (or any other kind of variant), formats
    // can choose whether to keep track of it by index or by name. Binary
    // formats typically use the index of the variant and human-readable formats
    // typically use the name.
    fn serialize_unit_variant(
        self,
        _name: &'static str,
        _variant_index: u32,
        variant: &'static str,
    ) -> Result<()> {
        self.serialize_str(variant)
    }

    // As is done here, serializers are encouraged to treat newtype structs as
    // insignificant wrappers around the data they contain.
    fn serialize_newtype_struct<T>(self, _name: &'static str, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        value.serialize(self)
    }

    // Note that newtype variant (and all of the other variant serialization
    // methods) refer exclusively to the "externally tagged" enum
    // representation.
    //
    // Serialize this in externally tagged form as `{ NAME: VALUE }`.
    fn serialize_newtype_variant<T>(
        self,
        _name: &'static str,
        _variant_index: u32,
        variant: &'static str,
        value: &T,
    ) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        self.begin_table(Some(1));
        self.begin_table_entry_key();
        variant.serialize(&mut *self)?;
        self.begin_table_entry_value();
        value.serialize(&mut *self)?;
        self.close_table()
    }

    // Now we get to the serialization of compound types.
    //
    // The start of the sequence, each value, and the end are three separate
    // method calls. This one is responsible only for serializing the start.
    //
    // The length of the sequence may or may not be known ahead of time. This
    // doesn't make a difference because the length is not represented
    // explicitly in the serialized form. Some serializers may only be able to
    // support sequences for which the length is known up front.
    fn serialize_seq(self, len: Option<usize>) -> Result<Self::SerializeSeq> {
        self.begin_table(len);
        Ok(self)
    }

    // Tuples are tables in Lua
    fn serialize_tuple(self, len: usize) -> Result<Self::SerializeTuple> {
        self.serialize_seq(Some(len))
    }

    // Tuple structs look just like sequences.
    fn serialize_tuple_struct(
        self,
        _name: &'static str,
        len: usize,
    ) -> Result<Self::SerializeTupleStruct> {
        self.serialize_seq(Some(len))
    }

    // Tuple variants are represented as `{ NAME: [DATA...] }`. Again this
    // method is only responsible for the externally tagged representation.
    fn serialize_tuple_variant(
        self,
        _name: &'static str,
        _variant_index: u32,
        variant: &'static str,
        len: usize,
    ) -> Result<Self::SerializeTupleVariant> {
        self.begin_table(Some(1));
        self.begin_table_entry_key();
        variant.serialize(&mut *self)?;
        self.begin_table_entry_value();
        self.begin_table(Some(len));
        Ok(self)
    }

    // Maps are represented as `{ K = V, K = V, ... }`.
    fn serialize_map(self, len: Option<usize>) -> Result<Self::SerializeMap> {
        self.begin_table(len);
        Ok(self)
    }

    // Structs look just like maps in Lua. In particular, Lua requires that we
    // serialize the field names of the struct. Other formats may be able to
    // omit the field names when serializing structs because the corresponding
    // Deserialize implementation is required to know what the keys are without
    // looking at the serialized data.
    fn serialize_struct(self, _name: &'static str, len: usize) -> Result<Self::SerializeStruct> {
        self.serialize_map(Some(len))
    }

    // Struct variants are represented in Lua as `{ NAME: { K: V, ... } }`.
    // This is the externally tagged representation.
    fn serialize_struct_variant(
        self,
        _name: &'static str,
        _variant_index: u32,
        variant: &'static str,
        len: usize,
    ) -> Result<Self::SerializeStructVariant> {
        self.begin_table(Some(1));
        self.begin_table_entry_key();
        variant.serialize(&mut *self)?;
        self.begin_table_entry_value();
        self.begin_table(Some(len));
        Ok(self)
    }
}

// The following 7 impls deal with the serialization of compound types like
// sequences and maps. Serialization of such types is begun by a Serializer
// method and followed by zero or more calls to serialize individual elements of
// the compound type and one call to end the compound type.
//
// This impl is SerializeSeq so these methods are called after `serialize_seq`
// is called on the Serializer.
impl ser::SerializeSeq for &mut Serializer {
    // Must match the `Ok` type of the serializer.
    type Ok = ();
    // Must match the `Error` type of the serializer.
    type Error = LuaSerializerError;

    // Serialize a single element of the sequence.
    fn serialize_element<T>(&mut self, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        value.serialize(&mut **self)
    }

    // Close the sequence.
    fn end(self) -> Result<()> {
        self.close_table()
    }
}

// Same thing but for tuples.
impl ser::SerializeTuple for &mut Serializer {
    type Ok = ();
    type Error = LuaSerializerError;

    fn serialize_element<T>(&mut self, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        value.serialize(&mut **self)
    }

    fn end(self) -> Result<()> {
        self.close_table()
    }
}

// Same thing but for tuple structs.
impl ser::SerializeTupleStruct for &mut Serializer {
    type Ok = ();
    type Error = LuaSerializerError;

    fn serialize_field<T>(&mut self, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        value.serialize(&mut **self)
    }

    fn end(self) -> Result<()> {
        self.close_table()
    }
}

// Tuple variants are a little different. Refer back to the
// `serialize_tuple_variant` method above. The `end` method
// in this impl is responsible for closing both the outer and
// inner tables.
impl ser::SerializeTupleVariant for &mut Serializer {
    type Ok = ();
    type Error = LuaSerializerError;

    fn serialize_field<T>(&mut self, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        value.serialize(&mut **self)
    }

    fn end(self) -> Result<()> {
        self.close_table()?;
        self.close_table()
    }
}

// Some `Serialize` types are not able to hold a key and value in memory at the
// same time so `SerializeMap` implementations are required to support
// `serialize_key` and `serialize_value` individually.
//
// There is a third optional method on the `SerializeMap` trait. The
// `serialize_entry` method allows serializers to optimize for the case where
// key and value are both available simultaneously.
impl ser::SerializeMap for &mut Serializer {
    type Ok = ();
    type Error = LuaSerializerError;

    // The Serde data model allows map keys to be any serializable type.
    fn serialize_key<T>(&mut self, key: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        self.begin_table_entry_key();
        key.serialize(&mut **self)
    }

    fn serialize_value<T>(&mut self, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        self.begin_table_entry_value();
        value.serialize(&mut **self)
    }

    fn end(self) -> Result<()> {
        self.close_table()
    }
}

// Structs are like maps in which the keys are constrained to be compile-time
// constant strings.
impl ser::SerializeStruct for &mut Serializer {
    type Ok = ();
    type Error = LuaSerializerError;

    fn serialize_field<T>(&mut self, key: &'static str, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        self.begin_table_entry_key();
        key.serialize(&mut **self)?;
        self.begin_table_entry_value();
        value.serialize(&mut **self)
    }

    fn end(self) -> Result<()> {
        self.close_table()
    }
}

// Similar to `SerializeTupleVariant`, here the `end` method is responsible for
// closing both of the curly braces opened by `serialize_struct_variant`.
impl ser::SerializeStructVariant for &mut Serializer {
    type Ok = ();
    type Error = LuaSerializerError;

    fn serialize_field<T>(&mut self, key: &'static str, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        self.begin_table_entry_key();
        key.serialize(&mut **self)?;
        self.begin_table_entry_value();
        value.serialize(&mut **self)
    }

    fn end(self) -> Result<()> {
        self.close_table()?;
        self.close_table()
    }
}

#[cfg(test)]
mod test {
    use std::collections::HashMap;

    use crate::nodes::{StringExpression, TableExpression};

    use super::*;

    macro_rules! expression {
        ($input:literal) => {{
            let mut block = $crate::Parser::default()
                .parse(concat!("return ", $input))
                .expect("expected code should parse");
            let last = block
                .take_last_statement()
                .expect("last statement should exist");

            match last {
                $crate::nodes::LastStatement::Return(statement) => {
                    assert_eq!(statement.len(), 1);
                    statement.into_iter_expressions().next().unwrap()
                }
                $crate::nodes::LastStatement::Break(_)
                | $crate::nodes::LastStatement::Continue(_) => {
                    panic!("unexpected last statement")
                }
            }
        }};
    }

    macro_rules! test_serialize {
        ($($name:ident($input:expr) => $value:expr),* $(,)?) => {
            $(
                #[test]
                fn $name() {
                    pretty_assertions::assert_eq!(
                        to_expression(&$input).unwrap(),
                        Expression::from($value),
                    );
                }
            )*
        };
    }

    test_serialize!(
        serializes_true_value(true) => true,
        serializes_false_value(false) => false,
        serializes_one_number_value(1) => expression!("1"),
        serializes_zero_as_i8(0_i8) => expression!("0"),
        serializes_zero_as_i16(0_i8) => expression!("0"),
        serializes_zero_as_u8(0_u8) => expression!("0"),
        serializes_zero_as_u16(0_u16) => expression!("0"),
        serializes_one_point_five_number_value(1.5) => expression!("1.5"),
        serializes_100_as_f32_number_value(100.0_f32) => expression!("100"),
        serializes_char_value('a') => StringExpression::from_value("a"),
        serializes_str_value("abc") => StringExpression::from_value("abc"),
        serializes_none_value(Option::<String>::None) => Expression::nil(),
        serializes_unit_value(()) => Expression::nil(),
        serializes_empty_vec_value(Vec::<bool>::new()) => TableExpression::default(),
        serializes_tuple_with_bool((true,)) => expression!("{ true }"),
        serializes_tuple_with_two_bool((false, true)) => expression!("{ false, true }"),
        serializes_vec_with_bool(vec![true]) => expression!("{ true }"),
        serializes_vec_with_two_bool(vec![true, false]) => expression!("{ true, false }"),
        serializes_slice_of_strings(["a", "b", "c"]) => expression!("{ \"a\", \"b\", \"c\" }"),
        serializes_slice_of_bytes(serde_bytes::Bytes::new("abc".as_bytes())) => expression!("string.char(0x61, 0x62, 0x63)"),
        serializes_empty_hash_map(HashMap::<usize, usize>::new()) => expression!("{}"),
        serializes_hash_map_with_string_to_bool({
            let mut map = HashMap::new();
            map.insert("oof", true);
            map
        }) => expression!("{ oof = true }"),
        serializes_hash_map_with_keyword_string_to_vec({
            let mut map = HashMap::new();
            map.insert("do", vec![1, 2, 3]);
            map
        }) => expression!("{ [\"do\"] = {1, 2, 3} }"),
        serializes_hash_map_with_bool_to_number({
            let mut map = HashMap::new();
            map.insert(false, 0);
            map
        }) => expression!("{ [false] = 0 }"),
        serializes_struct_with_int_field({
            #[derive(Serialize)]
            struct Test {
                int: u32,
            }

            Test { int: 1 }
        }) => expression!("{ int = 1 }"),
        serializes_struct_with_int_and_vec_fields({
            #[derive(Serialize)]
            struct Test {
                int: u32,
                seq: Vec<&'static str>,
            }

            Test {
                int: 1,
                seq: vec!["a", "b"],
            }
        }) => expression!("{ int = 1, seq = { 'a', 'b' } }"),
        serializes_enum_unit_variant({
            #[derive(Serialize)]
            enum Test {
                Unit,
            }

            Test::Unit
        }) => StringExpression::from_value("Unit"),
        serializes_enum_type_variant({
            #[derive(Serialize)]
            enum Test {
                Value(bool),
            }

            Test::Value(true)
        }) => expression!("{ Value = true }"),
        serializes_enum_tuple_variant({
            #[derive(Serialize)]
            enum Test {
                Tuple(&'static str, usize),
            }

            Test::Tuple("oof", 0)
        }) => expression!("{ Tuple = { 'oof', 0 } }"),
        serializes_enum_struct_variant({
            #[derive(Serialize)]
            enum Test {
                Struct {
                    field: &'static str,
                    pair: (bool, usize),
                    list: Vec<u32>,
                }
            }

            Test::Struct {
                field: "value",
                pair: (false, 10),
                list: vec![]
            }
        }) => expression!("{ Struct = { field = \"value\", pair = { false, 10 }, list = {} } }"),
        serializes_enum_struct_variant_internally_tagged({
            #[derive(Serialize)]
            #[serde(tag = "type")]
            enum Test {
                Struct {
                    field: &'static str,
                    pair: (bool, usize),
                    list: Vec<u32>,
                }
            }

            Test::Struct {
                field: "value",
                pair: (false, 10),
                list: vec![]
            }
        }) => expression!("{ type = \"Struct\", field = \"value\", pair = { false, 10 }, list = {} }"),
        serializes_enum_struct_variant_adjacently_tagged({
            #[derive(Serialize)]
            #[serde(tag = "type", content = "data")]
            enum Test {
                Struct {
                    field: &'static str,
                    pair: (bool, usize),
                    list: Vec<u32>,
                }
            }

            Test::Struct {
                field: "value",
                pair: (false, 10),
                list: vec![]
            }
        }) => expression!("{ type = \"Struct\", data = { field = \"value\", pair = { false, 10 }, list = {} } }"),
        serializes_enum_struct_variant_untagged({
            #[derive(Serialize)]
            #[serde(untagged)]
            enum Test {
                Struct {
                    field: &'static str,
                    pair: (bool, usize),
                    list: Vec<u32>,
                }
            }

            Test::Struct {
                field: "value",
                pair: (false, 10),
                list: vec![]
            }
        }) => expression!("{ field = \"value\", pair = { false, 10 }, list = {} }"),
        serializes_new_type_struct({
            #[derive(Serialize)]
            struct Test(String);

            Test("value".to_owned())
        }) => expression!("'value'"),
        serializes_tuple_struct({
            #[derive(Serialize)]
            struct Test(String, usize, String);

            Test("value".to_owned(), 1, "".to_owned())
        }) => expression!("{ 'value', 1, '' }"),
    );
}
