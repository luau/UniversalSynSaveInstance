local function generateNumber()
    return math.random(1, 9999)
end

return {
    zero = 0,
    one = 1,
    hex = 0x10,
    binary = 0b1010,
    number1 = generateNumber(),
    number2 = generateNumber(),
    number3 = generateNumber(),
}
