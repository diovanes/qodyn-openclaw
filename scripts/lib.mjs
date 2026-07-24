import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { execFileSync } from "node:child_process";
export const ROOT=path.resolve(path.dirname(new URL(import.meta.url).pathname),"..");
export const readJson=(file)=>JSON.parse(fs.readFileSync(file,"utf8"));
export const ensureDir=(dir)=>fs.mkdirSync(dir,{recursive:true});
export const walk=(dir)=>fs.existsSync(dir)?fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(dir,e.name)):[path.join(dir,e.name)]):[];
export const sha256=(file)=>crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex");
export function gitCommit(){try{return execFileSync("git",["rev-parse","HEAD"],{cwd:ROOT,encoding:"utf8",stdio:["ignore","pipe","ignore"]}).trim();}catch{return "unknown";}}
export function fail(m){console.error(`ERROR: ${m}`);process.exitCode=1;}
export function parseFrontMatter(text){if(!text.startsWith("---\n"))return {data:{},content:text};const end=text.indexOf("\n---\n",4);if(end<0)return {data:{},content:text};const raw=text.slice(4,end);const data={};for(const line of raw.split("\n")){const i=line.indexOf(":");if(i>0)data[line.slice(0,i).trim()]=line.slice(i+1).trim();}return {data,content:text.slice(end+5)};}
