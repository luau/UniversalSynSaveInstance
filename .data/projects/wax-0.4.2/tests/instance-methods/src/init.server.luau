print("All descendant GetFullName() results:")
for _, Ref in next, script:GetDescendants() do
    print(Ref:GetFullName())
end

print("\nAll children of `Child` folder:")
for _, Ref in next, script.Child:GetChildren() do
    print(Ref:GetFullName())
end

print("\nFindFirstChild() result for \"AScript\" under \"AnotherChild\":")
print(script.Child.AnotherChild:FindFirstChild("AScript"):GetFullName())
print("\nShould be the same for WaitForChild():")
print(script.Child.AnotherChild:WaitForChild("AScript", math.huge):GetFullName())

print("\nFindFirstAncestor() result for \"AnotherChild2\" above \"AnotherChild2/NestedChild/AScript\":")
print(script.Child.AnotherChild2.NestedChild.AScript:FindFirstAncestor("AnotherChild2"):GetFullName())
