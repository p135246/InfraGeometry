BeginTestSection[ "InfraSceneObject" ]

ClearAll[ objectPoint, objectEnd, objectSegment, objectUnknown, objectVertex ]

objectScene = InfraScene[
  PathGraph[ Range[ 5 ] ],
  { objectPoint, objectEnd, objectSegment },
  {
    InfraSceneStep[ { objectPoint == InfraPoint[ 1 ], objectEnd == InfraPoint[ 5 ] }, "points" ],
    InfraSceneStep[ { objectSegment == InfraSegment[ objectPoint, objectEnd ] }, "segment" ]
  }
];

objectInstance = RandomInfraSceneInstance[ objectScene, RandomSeeding -> 7 ];

VerificationTest[
  { Head[ objectInstance ], objectInstance[ "Substrate" ] === objectScene[ "Substrate" ],
    objectInstance[ "Hypotheses" ] === objectScene[ "Hypotheses" ], objectInstance[ "Labels" ] },
  { InfraScene, True, True, { "points", "segment" } },
  TestID -> "InfraSceneObject-retains-head-substrate-hypotheses-and-steps"
]

VerificationTest[
  { objectScene[ "Parameters" ], objectInstance[ "Parameters" ] },
  { { objectPoint, objectEnd, objectSegment },
    { objectPoint -> 1, objectEnd -> 5, objectSegment -> { 1, 2, 3, 4, 5 } } },
  TestID -> "InfraSceneObject-parameters-in-declaration-order"
]

VerificationTest[
  { MemberQ[ objectScene[ "Properties" ], "Graphics" ],
    ContainsAll[ objectInstance[ "Properties" ], { "Graphics", "Parameters", "Substrate", "Hypotheses", "Properties" } ],
    Head[ objectInstance[ "unknown" ] ] },
  { False, True, objectInstance },
  TestID -> "InfraSceneObject-supported-and-unknown-properties"
]

VerificationTest[
  InfraSceneInstance[ objectInstance, { objectPoint, objectSegment } ],
  { 1, { 1, 2, 3, 4, 5 } },
  TestID -> "InfraSceneObject-compatibility-accessor"
]

VerificationTest[
  With[ { scene = InfraScene[ CycleGraph[ 4 ], { objectPoint }, { objectPoint == InfraPoint[] } ] },
    { RandomInfraSceneInstance[ scene, RandomSeeding -> 17 ][ "Parameters" ] ===
        RandomInfraSceneInstance[ scene, RandomSeeding -> 17 ][ "Parameters" ],
      Length[ RandomInfraSceneInstance[ scene, All ] ],
      Head /@ RandomInfraSceneInstance[ scene, 2 ],
      RandomInfraSceneInstance[ scene, 5 ],
      RandomInfraSceneInstance[ scene, 0 ],
      RandomInfraSceneInstance[ scene, UpTo[ 0 ] ],
      Length[ RandomInfraSceneInstance[ scene, UpTo[ 10 ] ] ] } ],
  { True, 4, { InfraScene, InfraScene }, {}, {}, {}, 4 },
  TestID -> "InfraSceneObject-seeding-counts-shortage-and-zero"
]

VerificationTest[
  With[ { partial = RandomInfraSceneInstance[ objectScene, "Steps" -> 1 ] },
    { partial[ "Parameters" ], RandomInfraSceneInstance[ partial ][ "Parameters" ],
      RandomInfraSceneInstance[ objectScene, <| objectEnd -> 5 |> ][ "Parameters" ] } ],
  { { objectPoint -> 1, objectEnd -> 5 }, objectInstance[ "Parameters" ], objectInstance[ "Parameters" ] },
  TestID -> "InfraSceneObject-partial-bindings-continuation-and-init"
]

VerificationTest[
  With[ { scene = InfraScene[ PathGraph[ Range[ 3 ] ], { objectPoint },
      { objectPoint == InfraPoint[], InfraDistance[ objectPoint, 1 ] > 10 } ] },
    RandomInfraSceneInstance[ scene ] ],
  {},
  TestID -> "InfraSceneObject-impossible-assertion"
]

VerificationTest[
  { MatchQ[ InfraScene[ PathGraph[ Range[ 3 ] ], { objectPoint }, { InfraObjectUnknownQ[ objectPoint ] } ],
      InfraScene[ _Graph, _List, _List ] ],
    Head[ RandomInfraSceneInstance[ InfraScene[ PathGraph[ Range[ 3 ] ], { objectPoint },
      { objectPoint == objectUnknown[ 1 ] } ] ] ] },
  { True, RandomInfraSceneInstance },
  TestID -> "InfraSceneObject-unsupported-construction-stays-unevaluated"
]

VerificationTest[
  With[ { legacy = InfraScene[ { objectPoint }, { objectPoint == InfraPoint[ 1 ] } ] },
    { Head[ RandomInfraSceneInstance[ legacy, PathGraph[ Range[ 3 ] ] ] ],
      InfraSceneInstance[ RandomInfraSceneInstance[ legacy, PathGraph[ Range[ 3 ] ] ], objectPoint ] } ],
  { InfraSceneInstance, 1 },
  TestID -> "InfraSceneObject-legacy-sampler-retains-return-type"
]

VerificationTest[
  { GraphQ[ objectInstance[ "Graphics" ] ], GraphQ[ InfraScenePlot[ objectInstance, { objectSegment } ] ],
    ImageSize /. Options[ objectInstance[ "Graphics", ImageSize -> 321 ] ] },
  { True, True, 321 },
  TestID -> "InfraSceneObject-graphics-and-display-selection-options"
]

VerificationTest[
  With[ { partial = RandomInfraSceneInstance[ objectScene, "Steps" -> 1 ] },
    GraphQ[ partial[ "Graphics" ] ] ],
  True,
  TestID -> "InfraSceneObject-partial-instance-renders-bound-objects"
]

VerificationTest[
  Block[ { InfraSubstrateHighlight },
    InfraSubstrateHighlight[ _Graph, objects_, ___ ] := objects;
    InfraScenePlot[ objectInstance, { objectSegment } ] ],
  { InfraWalk[ { 1, 2, 3, 4, 5 } ] },
  TestID -> "InfraSceneObject-graphics-draws-saved-path"
]

VerificationTest[
  With[ { scene = InfraScene[ Graph[ { { 1, 2 }, objectVertex[ 1 ], 3 },
        { { 1, 2 } <-> objectVertex[ 1 ], objectVertex[ 1 ] <-> 3 } ],
      { objectPoint, objectEnd, objectSegment },
      { objectPoint == InfraPoint[ { 1, 2 } ], objectEnd == InfraPoint[ 3 ],
        objectSegment == InfraSegment[ objectPoint, objectEnd ] } ] },
    { instance = RandomInfraSceneInstance[ scene ] },
    { InfraSceneInstance[ instance, objectPoint ], GraphQ[ instance[ "Graphics" ] ] } ],
  { { 1, 2 }, True },
  TestID -> "InfraSceneObject-structured-vertex-labels"
]

VerificationTest[
  Block[ { RandomInfraSceneInstance },
    RandomInfraSceneInstance[ ___ ] := Throw[ "resampled" ];
    Catch[ { GraphQ[ objectInstance[ "Graphics" ] ],
      MatchQ[ ToBoxes[ objectInstance, StandardForm ], _InterpretationBox ],
      MatchQ[ ToBoxes[ objectInstance, TraditionalForm ], FormBox[ _InterpretationBox, TraditionalForm ] ],
      FreeQ[ ToBoxes[ objectInstance, StandardForm ], _MakeBoxes ] } ] ],
  { True, True, True, True },
  TestID -> "InfraSceneObject-rendering-and-boxing-do-not-sample"
]

VerificationTest[
  With[ { saved = objectInstance },
    Extract[ MakeBoxes[ saved, StandardForm ], { 2 }, HoldComplete ] === HoldComplete[ saved ] ],
  True,
  TestID -> "InfraSceneObject-boxes-preserve-exact-interpretation"
]

VerificationTest[
  SeedRandom[ 345 ];
  With[ { expected = RandomInteger[ 10^6, 6 ] },
    SeedRandom[ 345 ];
    objectInstance[ "Graphics" ];
    ToBoxes[ objectInstance, StandardForm ];
    RandomInteger[ 10^6, 6 ] === expected ],
  True,
  TestID -> "InfraSceneObject-rendering-preserves-random-state"
]

VerificationTest[
  FreeQ[ InfraSceneViewer[ objectInstance ], $Failed ],
  True,
  TestID -> "InfraSceneObject-bound-viewer-constructs"
]

VerificationTest[
  With[ { paired = InfraSubstrate[ { "SquareGridGraph", { 4, 4 } }, "Default",
        "KeepCoordinates" -> True, ImageSize -> 210 ],
      legacy = InfraSubstrate[ "SquareGridGraph", { 4, 4 }, "Default",
        "KeepCoordinates" -> True, ImageSize -> 210 ] },
    { VertexList[ paired ] === VertexList[ legacy ], EdgeList[ paired ] === EdgeList[ legacy ],
      GraphEmbedding[ paired ] === GraphEmbedding[ legacy ], ImageSize /. Options[ paired ] } ],
  { True, True, True, 210 },
  TestID -> "InfraSubstrate-pair-syntax-forwards-size-style-and-options"
]

VerificationTest[
  With[ { graph = InfraSubstrate[ "SquareGridGraph", "KeepCoordinates" -> True, ImageSize -> 211 ] },
    { GraphQ[ graph ], VertexCount[ graph ] === VertexCount[ InfraSubstrate[ { "SquareGridGraph", "Medium" } ] ],
      ImageSize /. Options[ graph ] } ],
  { True, True, 211 },
  TestID -> "InfraSubstrate-default-size-with-options"
]

VerificationTest[
  InfraSubstrateCode[ { "SquareGridGraph", { 4, 4 } }, "KeepCoordinates" -> True ] ===
    InfraSubstrateCode[ "SquareGridGraph", { 4, 4 }, "KeepCoordinates" -> True ],
  True,
  TestID -> "InfraSubstrateCode-pair-syntax"
]

EndTestSection[]
