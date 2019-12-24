# Package

version       = "0.1.0"
author        = "Jeremy"
description   = "Are we alone? Exploring the Fermi Paradox"
license       = "MIT"
srcDir        = "src"
bin           = @["fermi"]

backend       = "cpp"

# Dependencies

requires "nim >= 1.0.4",
         "ggplotnim"
