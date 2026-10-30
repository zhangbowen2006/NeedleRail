import fs from 'node:fs';
import path from 'node:path';
import {compile_json} from '../_build/js/release/build/bridge/bridge.js';
const args=process.argv.slice(2);
if(args.length!==2){console.error('Usage: node scripts/cli.mjs job.json output-prefix');process.exit(2);}
let staging;
const staged=[];
const published=[];
function sameFile(filename, identity) {
  try {
    const now=fs.lstatSync(filename,{bigint:true});
    return now.isFile() && identity.ino!==0n && now.ino===identity.ino && now.dev===identity.dev;
  } catch { return false; }
}
function cleanStaging() {
  for(const item of staged) {
    try { if(sameFile(item.filename,item.identity))fs.unlinkSync(item.filename); }
    catch(e) { console.error('Could not clean staging file: '+e.message); }
  }
  if(staging) {
    // Never recursively delete: leave unexpected files in the private directory.
    try { fs.rmdirSync(staging); }
    catch(e) { console.error('Could not remove staging directory: '+e.message); }
  }
}
try {
  const result=JSON.parse(compile_json(fs.readFileSync(args[0],'utf8')));
  if(result.error)throw new Error(result.error);
  const outputs=[['.dst',Buffer.from(result.dst_bytes)],['.svg',result.svg],['.json',JSON.stringify(result.report,null,2)+'\n']];
  const prefix=path.resolve(args[1]);
  for(const [ext] of outputs)if(fs.existsSync(prefix+ext))throw new Error('Output exists: '+prefix+ext);
  const directory=path.dirname(prefix);
  fs.mkdirSync(directory,{recursive:true});
  staging=fs.mkdtempSync(path.join(directory,'.needlerail-'));
  // Prepare every artifact before publishing any destination name. Hard links
  // stay on this filesystem and fail atomically if a destination already exists.
  for(const [ext,data] of outputs) {
    const filename=path.join(staging,'artifact'+ext);
    const descriptor=fs.openSync(filename,'wx');
    try {
      staged.push({filename,destination:prefix+ext,identity:fs.fstatSync(descriptor,{bigint:true})});
      fs.writeFileSync(descriptor,data);
    } finally { fs.closeSync(descriptor); }
  }
  for(const item of staged) {
    fs.linkSync(item.filename,item.destination);
    published.push(item);
  }
  cleanStaging();
  console.log(JSON.stringify({prefix:args[1],stitches:result.report.stitches,jumps:result.report.jumps,color_changes:result.report.color_changes}));
}catch(e){
  // A failed link may mean another process created the destination. Only remove
  // our own successfully linked files, and leave replacements by others intact.
  for(const item of published.reverse()) {
    try { if(sameFile(item.destination,item.identity))fs.unlinkSync(item.destination); }
    catch(cleanupError) { console.error('Could not roll back output: '+cleanupError.message); }
  }
  cleanStaging();
  console.error(e.message);process.exitCode=2;
}
