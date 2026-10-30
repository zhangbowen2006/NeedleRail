import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {compile_json} from '../_build/js/release/build/bridge/bridge.js';
const run=job=>JSON.parse(compile_json(JSON.stringify(job)));
for(const name of ['outline','satin','patch'])test(`complete ${name} job generates bounded DST, SVG and report`,()=>{
  const job=JSON.parse(fs.readFileSync(new URL(`../examples/${name}.json`,import.meta.url)));
  const out=run(job);assert.equal(out.error,undefined);
  const report=out.report;let prev={x:0,y:0};
  assert.equal(report.commands.at(-1).kind,'end');
  assert.equal(report.commands.filter(c=>c.kind==='end').length,1);
  for(const c of report.commands){
    assert.ok(Math.abs(c.x)*2<=job.width && Math.abs(c.y)*2<=job.height);
    if(c.kind==='stitch')assert.ok(Math.hypot(c.x-prev.x,c.y-prev.y)<=job.max_step+1e-9);
    if(c.kind==='jump')assert.ok(Math.hypot(c.x-prev.x,c.y-prev.y)<=121+1e-9);
    prev=c;
  }
  if(name==='patch')for(const c of report.commands)if(c.kind==='stitch')assert.ok(!(c.x>-100&&c.x<100&&c.y>-100&&c.y<100));
  assert.equal(out.dst_bytes.length,512+report.commands.length*3);
  assert.equal(out.dst_bytes.at(-1),243);assert.ok(out.svg.endsWith('</svg>'));
  const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'needlerail-'));
  try{
    const prefix=path.join(tmp,name);
    const p=spawnSync(process.execPath,['scripts/cli.mjs',`examples/${name}.json`,prefix],{encoding:'utf8'});
    assert.equal(p.status,0,p.stderr);
    assert.deepEqual([...fs.readFileSync(prefix+'.dst')],out.dst_bytes);
    const duplicate=spawnSync(process.execPath,['scripts/cli.mjs',`examples/${name}.json`,prefix],{encoding:'utf8'});
    assert.equal(duplicate.status,2);assert.match(duplicate.stderr,/exists/);
  }finally{fs.rmSync(tmp,{recursive:true,force:true});}
});
test('invalid geometry and input types fail without producing files',()=>{
  const job={width:1000,height:1000,max_step:25,objects:[{kind:'running',thread:0,path:[[0,0],[100,100]]}]};
  assert.ok(run({...job,max_step:25.5}).error);
  assert.ok(run({...job,objects:[{kind:'running',thread:0,path:[[0,0],[100.1,100]]}]}).error);
  assert.ok(run({...job,width:100}).error);
  assert.ok(JSON.parse(compile_json('{"width":1000,"width":500}')).error);
  assert.ok(run({...job,objects:[{kind:'fill',thread:0,spacing:10,rings:[[[0,0],[100,100],[0,100],[100,0]]]}]}).error);
});
