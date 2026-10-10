---@class Enum
Enum = {}
-----------------------------------------------------------
Enum.AccessoryType = {
    Unknown = 0,
    Hat = 1,
    Hair = 2,
    Face = 3,
    Neck = 4,
    Shoulder = 5,
    Front = 6,
    Back = 7,
}
Enum.CameraMode = {
    Classic = 0,
    LockFirstPerson = 0
}
Enum.CameraPanMode = {
    Classic = 0,
    EdgeBump = 1,
}
Enum.RaycastFilterType = {
    Blacklist = 0,
    Whitelist = 1,
}
Enum.PartType = {
    Ball = 0,
    Block = 0,
    Cylinder = 0,
}
Enum.SurfaceType = {
    Smooth = 0,
    Glue = 1,
    Weld = 2,
    Studs = 3,
    Inlet = 4,
    Universal = 5,
    Hinge = 6,
    Motor = 7,
    SteppingMotor = 8,
    SmoothNoOutlines = 10,
}
Enum.EasingDirection = {
    In = 0,
    Out = 1,
    InOut = 2,
}
Enum.EasingStyle = {
    Linear = 0,
    Sine = 1,
    Back = 2,
    Quad = 3,
    Quart = 4,
    Quint = 5,
    Bounce = 6,
    Elastic = 7,
    Exponential = 8,
    Circular = 9,
    Cubic = 10,
}
Enum.Material = {
    Plastic = 256, --Applies to BasePart only.
    SmoothPlastic = 272, --Applies to BasePart only.
    Neon = 288, --Applies to BasePart only.
    Wood = 512, --Applies to BasePart only.
    WoodPlanks = 528, --Applies to BasePart and Terrain.
    Marble = 784, --Applies to BasePart only.
    Basalt = 788, --Applies to Terrain only.
    Slate = 800, --Applies to BasePart and Terrain.
    CrackedLava = 804, --Applies to Terrain only.
    Concrete = 816, --Applies to BasePart and Terrain.
    Limestone = 820, --Applies to Terrain only.
    Granite = 832, --Applies to BasePart only.
    Pavement = 836, --Applies to Terrain only.
    Brick = 848, --Applies to BasePart and Terrain.
    Pebble = 864, --Applies to BasePart only.
    Cobblestone = 880, --Applies to BasePart and Terrain.
    Rock = 896, --Applies to Terrain only.
    Sandstone = 912, --Applies to Terrain only.
    CorrodedMetal = 1040, --Applies to BasePart only.
    DiamondPlate = 1056, --Applies to BasePart only.
    Foil = 1072, --Applies to BasePart only.
    Metal = 1088, --Applies to BasePart only.
    Grass = 1280, --Applies to BasePart and Terrain.
    LeafyGrass = 1284, --Applies to Terrain only.
    Sand = 1296, --Applies to BasePart and Terrain.
    Fabric = 1312, --Applies to BasePart only.
    Snow = 1328, --Applies to Terrain only.
    Mud = 1344, --Applies to Terrain only.
    Ground = 1360, --Applies to Terrain only.
    Asphalt = 1376, --Applies to Terrain only.
    Salt = 1392, --Applies to Terrain only.
    Ice = 1536, --Applies to BasePart and Terrain.
    Glacier = 1552, --Applies to Terrain only.
    Glass = 1568, --Applies to BasePart only.
    ForceField = 1584, --Applies to BasePart only.
    Air = 1792, --Applies to Terrain only.
    Water = 2048, --Applies to Terrain only.
}
Enum.ThumbnailType = {
    HeadShot = 0,
    AvatarBust = 0,
    AvatarThumbnail = 0,
}
Enum.ThumbnailSize = {
    Size48x48 = 0,
    Size180x180 = 1,
    Size420x420 = 2,
    Size60x60 = 3,
    Size100x100 = 4,
    Size150x150 = 5,
    Size352x352 = 6,
}