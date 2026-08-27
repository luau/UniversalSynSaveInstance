assert(gethiddenproperty, "Executor is missing gethiddenproperty, aborting test")
local identify_executor = identifyexecutor or getexecutorname or whatexecutor
local EXECUTOR_NAME = identify_executor and identify_executor() or "Missing identifyexecutor Function"

local PassedTests, FailedTests, NotTested, NilResults = 0, 0, 0, 0

local function test(instance, propertyname, valuetype)
	if instance then
		local ok, result = pcall(gethiddenproperty, instance, propertyname)

		if
			not ok
			or result == nil
			or (type(result) == "string" and string.find(result, "Unable to get property ", 1, true))
		then
			print("⛔ " .. valuetype .. " " .. tostring(result))
			FailedTests += 1
		else
			print("✅ " .. valuetype)
			PassedTests += 1
		end
	else
		print("⏺ " .. valuetype)
		NotTested += 1
	end
end
local function findinstance(classname)
	return game:FindFirstChildWhichIsA(classname, true)
end

print("gethiddenproperty Types Test")
print("Executor: " .. EXECUTOR_NAME)
print("✅ - Pass, ⛔ - Fail, 🟠 - Output is nil, ⏺️ - No test")

local test_WRAPLAYER = Instance.new("WrapLayer")
local test_PART = Instance.new("Part")
local test_WELDCONSTRAINT = Instance.new("WeldConstraint")
test_WELDCONSTRAINT.Part0 = test_PART
local test_UNION = Instance.new("UnionOperation")
local test_MODEL = Instance.new("Model")
test_MODEL.WorldPivot = CFrame.new(1, 2, 3)

test(workspace, "ExplicitAutoJoints", "bool")
test(UserSettings().GameSettings, "gaID", "string")
test(workspace, "StreamingTargetRadius", "int")
test(findinstance("TextSource"), "UserIdReplicated", "int64")
test(Instance.new("Sound"), "TimePositionReplicator", "double")
test(workspace.Terrain, "GrassLength", "float")
test(Instance.new("InputAction"), "Direction2DState", "Vector2")
test(test_PART, "size", "Vector3")
test(test_PART, "Origin", "CFrame")
test(test_WRAPLAYER, "Color", "Color3")
test(Instance.new("UIListLayout"), "HorizontalPadding", "UDim")
test(test_WRAPLAYER, "HSRAssetId", "ContentId")
test(findinstance("Clothing"), "Outfit1Content", "Content")

test(Instance.new("TerrainRegion"), "ExtentsMax", "Vector3int16")

test(workspace, "StreamOutBehavior", "Category:Enum")
test(test_WELDCONSTRAINT, "Part0Internal", "Category:Class")
test(Instance.new("AnimationRigData"), "parent", "BinaryString")
test(Instance.new("Script"), "CachedRemoteSource", "ProtectedString")

test(test_WRAPLAYER, "HSRData", "SharedString")

test(workspace, "UniqueId", "UniqueId")
test(test_PART, "NetworkOwnerV3", "SystemAddress")

test(test_PART, "Color3uint8", "Color3uint8")
test(test_MODEL, "WorldPivotData", "OptionalCoordinateFrame")
test(test_UNION, "DCDPropertyData", "CSGPropertyData")
test(test_UNION, "SolidMeshHolder", "NetAssetRef")
test(test_PART, "ReplicationPV", "ReplicationPV")
test(Instance.new("Animator"), "FacsReplicationData", "FacsReplicationData")
test(workspace.Terrain, "VoxelGridAssetContentMap", "AssetContentMap")
test(findinstance("Animator"), "AnimTrackMetadata0", "AnimTrackMetadata")
test(findinstance("Animator"), "AnimTrackPlayState0", "AnimTrackPlayState")
test(findinstance("Animator"), "AnimTrackWeight0", "AnimTrackWeight")
test(
	game:GetService("AssetService"):CreateEditableImage({
		Size = Vector2.new(256, 256),
	}),
	"ImageData",
	"Property of Object, not Instance"
)

local fullfails = FailedTests + NilResults
local rate = math.round(PassedTests / (PassedTests + fullfails) * 100)
local outOf = PassedTests .. " out of " .. (PassedTests + fullfails)

print("\n")
print("gethiddenproperty Types Summary")
print("✅ Tested with a " .. rate .. "% success rate (" .. outOf .. ")")
print("⛔ " .. FailedTests .. " tests failed")
print("🟠 " .. NilResults .. " types resulted in a nil value")
print("⏺️ " .. NotTested .. " types were not tested")
