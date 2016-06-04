//
//  testData.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation

let F2LFormulas = [ "(R U' U' R' U)2 y' (R' U' R)",
                    "(U R U' R' U') y' (R' U R)",
                    "U' (F' R U R' U') (R' F R)",
                    "(R U R' U') (R U' U' R' U') (R U R')",
                    "(R U'R U) y (R U' R' F2)",
                    "y' (R' U' R U) (R' U' R)",
                    "(R U' R' U) (R U' R')",
                    "(R U' R' U) (R U' U' R' U) (R U' R')",
                    "R2 y (R U R' U') y' (R' U R')",
                    "y' (R' U) (R U') (R' U R)",
                    "(R U R' U') (R U R')",
                    "(R U R' U')2 (R U R')",
                    "(R U' R') y' (R' U2 R)",
                    "y' (R' U2) (R U R' U') R",
                    "y' U' (R' U2) (R U' R' U) R",
                    "y' (R' U R U' U') (R' U' R)",
                    "(R U R' U) (R U' U' R' d) (R' U R)",
                    "(R U R') U2 (R U R' U') (R U R')",
                    "(R U' R' U2) (R U R')",
                    "U (R U' U') (R' U R U') R'",
                    "(R U' U') (R' U'R U) R'",
                    "U' (R U' ) (R' U2) (R U' R')",
                    "U' (R U R') d (R' U' R)",
                    "d (R' U R U') (R' U' R)",
                    "y' (R' U' R)",
                    "d R' U' R U') (R' U' R)",
                    "y' (R U' U') R'2 U' R2 U' R'",
                    "y' (R' U) (R d' U') (R U R')",
                    "U' (R U' U') (R' U2) (R U' R')",
                    "U' (R U R' U') (R U' U' R')",
                    "U R U' R'",
                    "U' (R U' U' R' U) (R U R')",
                    "d (R' U' R) d' (R U R')",
                    "y' U' (R' U R)",
                    "d R' U'R U' U') (R' U R)",
                    "d (R' U2) (R U' U') (R' U R)",
                    "(R U' R' U) (d R' U' R)",
                    "(R U')(R' U) (R U') (R' U2) (R U' R')",
                    "U' (R U R' U) (R U R')",
                    "(R U R')",
                    "U' (R U' R' U) (R U R')",]

let OLLFormulas = ["(R U' U') (R2' F R F') U2 (R' F R F')",
                   "(F R U R' U' F') (f R U R' U' f')",
                   "f (R U R' U') f' U' F (R U R' U') F'",
                   "f (R U R' U') y  x (R' F)(R U R' U') F'",
                   "(r' U2) (R U R' U) r",
                   "(r U' U') (R' U' R U' r')",
                   "r U R' U R U' U' r'",
                   "r' U' R U' R' U2 r",
                   "(R' U' R) y' x' (R U')(R' F) (R U R')",
                   "(R U R' U)(R' F R F') (R U' U' R')",
                   "r' (R2 U R' U)(R U' U' R' U) (r R')",
                   "(r R'2 U' R U')(R' U2 R U' R) r'",
                   "(r U' r' U')(r U r') (F' U F)",
                   "R' F R U R' F' R (F U' F')",
                   "(r' U' r) (R'U'R U) (r' U r)",
                   "(r U r') (R U R' U') (r U' r')",
                   "F (U R' U' F') U (F R2 U R' U' F')",
                   "F (R U R' d) (R' U2) (R' F R F')",
                   "(r' R U) (R U R' U' r) (R'2 F R F')",
                   "r' (R U) (R U R' U' r2) (R2' U) (R U') r'",
                   "(R U' U') (R' U' R U R' U') (R U' R')",
                   "R U' U' (R'2 U') (R2 U') R'2 U2 R",
                   "(R2 D') (R U' U') (R' D) (R U' U' R)",
                   "(r U R' U') (r' F R F')",
                   "F' (r U R' U') (r' F R)",
                   "R U' U' R' U' R U' R'",
                   "R' U2 R U R' U R",
                   "(r U R' U') (r' R U) (R U' R')",
                   "(r U R' U')(R r'2 F R F') (r R')",
                   "(R2 U R' B') (R U') (R2' U) (R B R')",
                   "(r' F' U F) (L F' L' U' r)",
                   "(R U) (B' U') (R' U R B R')",
                   "(R U R' U') (R' F R F')",
                   "(R' U' R U) y(r U R' U') r' R",
                   "R U' U' R2' F R F' (R U' U' R')",
                   "R' U' R U' R' U R U l U' R' U",
                   "F (R U' R' U' R U) (R' F')",
                   "(R U R' U) (R U' R' U') (R' F R F')",
                   "(r U' r' U' r) y (R U R' f')",
                   "(R' F R U R'U') (F' U R)",
                   "R U' R' U2 R U y R U' R' U' F'",
                   "(R' U R U' U' R' U')(F' U)(F U R)",
                   "(B' U') (R' U R B)",
                   "f (R U R' U') f'",
                   "F (R U R' U') F'",
                   "(R' U') R' F R F' (U R)",
                   "B'(R' U' R U)2 B",
                   "F (R U R' U')2 F'",
                   "R B' (R2 F) (R2 B) R2 F' R",
                   "L' B (L2 F')(L2 B') L2 F L'",
                   "f (R U R' U')2 f'",
                   "R' U' R U' R' d R' U l U",
                   "(r' U2) (R U R' U') (R U R' U) r",
                   "(r U' U') (R' U' R U R' U') (R U' r')",
                   "(R U' U') (R'2 U') R U' R' U2 (F R F')",
                   "F (R U R' U')(R F')(r U R' U') r'",
                   "(R U R' U' r) (R' U) (R U' r')",]

let PLLFormula = [ "(R U' R) U (R U R U') (R' U' R2)",
                   "(R2' U) (R U R' U') (R' U') (R' U R')",
                   "M2 U M2 U2 M2 U M2",
                   "(U R' U') (R U' R) U (R U' R' U)(R U R2 U')(R' U)",
                   "x' R2 D2 (R' U' R) D2 (R' U R')",
                   "x' (R U' R) D2 (R' U R) D2 R2",
                   "x' (R U' R') D (R U R') u2' (R' U R) D (R' U' R)",
                   "(R U R' U') (R' F) (R2 U' R' U') (R U R' F')",
                   "U' (R' U R U' R'2 b') x (R' U R) y' (R U R' U' R2)",
                   "(R' U R' U') y x2 (R' U R' U' R2) x z' (R' U' R U R)",
                   "F (R U'R' U') (R U R' F') (R U R' U') (R' F R F')",
                   "z (U' R D') (R2 U R' U' R2 U) D R'",
                   "(R U R' F') (R U R' U') (R' F R2 U' R' U')",
                   "(R' U2) (R U' U') (R' F R U R' U') (R'F' R2 U')",
                   "(R U' U') (R' U2) (R B' R' U') (R U R B R2' U)",
                   "(R2' u' R U' R) (U R' u) (R2 B U'B')",
                   "(R U R') y' (R2' u' R U') (R' U R' u R2)",
                   "(R2 u R') (U R' U' R u') (R2' F' U F)",
                   "(R' d' F) (R2 u) (R' U) (R U' R u' R2)",
                   "z (R' U R') z' (R U2 L' U R') z (U R') z' (R U2 L' U R')",
                   "z (U' R D') (R2 U R' U') z' (R U R') z (R2 U R') z' (R U')",]

















