declare wax: {
    version: string,
    envname: string,
    shared: {[any]: any},

    script: LuaSourceContainer,

    require: (...any) -> ...any,
}
