import fs from "node:fs"; import path from "node:path"; import {ROOT} from "./lib.mjs"; for(const n of ["dist","artifacts"]) fs.rmSync(path.join(ROOT,n),{recursive:true,force:true});
