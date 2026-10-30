import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';

const root=fileURLToPath(new URL('../',import.meta.url));
const preload=new URL('./cli-failure-preload.mjs',import.meta.url).href;
for(const mode of ['second-write','second-link','concurrent-target','replaced-first']) {
  test(`CLI publication rollback: ${mode}`,()=>{
    const temporary=fs.mkdtempSync(path.join(os.tmpdir(),'needlerail-publish-'));
    const prefix=path.join(temporary,'result');
    try {
      const output=spawnSync(process.execPath,['--import',preload,'scripts/cli.mjs','examples/outline.json',prefix],{
        cwd:root,encoding:'utf8',env:{...process.env,NEEDLERAIL_TEST_FAILURE:mode}
      });
      assert.equal(output.status,2,output.stderr);
      assert.match(output.stderr,/Injected/);
      if(mode==='concurrent-target') {
        assert.equal(fs.readFileSync(prefix+'.svg','utf8'),'other process output');
        assert.ok(!fs.existsSync(prefix+'.dst'));
      } else if(mode==='replaced-first') {
        assert.equal(fs.readFileSync(prefix+'.dst','utf8'),'replacement from other process');
        assert.ok(!fs.existsSync(prefix+'.svg'));
      } else {
        assert.ok(!fs.existsSync(prefix+'.dst'));
        assert.ok(!fs.existsSync(prefix+'.svg'));
        // Failure leaves no incomplete owned artifacts, and normal retry works.
        const retry=spawnSync(process.execPath,['scripts/cli.mjs','examples/outline.json',prefix],{cwd:root,encoding:'utf8'});
        assert.equal(retry.status,0,retry.stderr);
      }
      assert.equal(fs.existsSync(prefix+'.json'),mode==='second-link'||mode==='second-write');
      assert.ok(fs.readdirSync(temporary).every(name=>!name.startsWith('.needlerail-')));
    } finally {
      // Only delete this exact directory returned by mkdtemp inside the OS temp.
      assert.equal(path.dirname(path.resolve(temporary)),path.resolve(os.tmpdir()));
      fs.rmSync(temporary,{recursive:true,force:true});
    }
  });
}
