// Test-only preload. No failure injection hooks exist in the production CLI.
import fs from 'node:fs';
const link=fs.linkSync;
const write=fs.writeFileSync;
let writes=0;
fs.writeFileSync=function(filename,...args) {
  if(process.env.NEEDLERAIL_TEST_FAILURE==='second-write' && typeof filename==='number' && ++writes===2) {
    write.call(this,filename,'partial');
    throw new Error('Injected staging write failure');
  }
  return write.call(this,filename,...args);
};
let calls=0;
fs.linkSync=function(source,destination,...rest) {
  calls++;
  if(calls===2) {
    if(process.env.NEEDLERAIL_TEST_FAILURE==='concurrent-target') {
      fs.writeFileSync(destination,'other process output',{flag:'wx'});
      const error=new Error('Injected destination race');error.code='EEXIST';throw error;
    }
    if(process.env.NEEDLERAIL_TEST_FAILURE==='replaced-first') {
      const first=destination.replace(/\.svg$/,'.dst');
      fs.unlinkSync(first);
      fs.writeFileSync(first,'replacement from other process',{flag:'wx'});
    }
    throw new Error('Injected publication failure');
  }
  return link.call(this,source,destination,...rest);
};
