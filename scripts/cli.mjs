import fs from 'node:fs';
import path from 'node:path';
import {compile_json} from '../_build/js/release/build/bridge/bridge.js';
const args=process.argv.slice(2);
if(args.length!==2){console.error('Usage: node scripts/cli.mjs job.json output-prefix');process.exit(2);}
try {
  const result=JSON.parse(compile_json(fs.readFileSync(args[0],'utf8')));
  if(result.error)throw new Error(result.error);
  const outputs=[['.dst',Buffer.from(result.dst_bytes)],['.svg',result.svg],['.json',JSON.stringify(result.report,null,2)+'\n']];
  for(const [ext] of outputs)if(fs.existsSync(args[1]+ext))throw new Error('Output exists: '+args[1]+ext);
  fs.mkdirSync(path.dirname(args[1]),{recursive:true});
  for(const [ext,data] of outputs)fs.writeFileSync(args[1]+ext,data,{flag:'wx'});
  console.log(JSON.stringify({prefix:args[1],stitches:result.report.stitches,jumps:result.report.jumps,color_changes:result.report.color_changes}));
}catch(e){console.error(e.message);process.exitCode=2;}
