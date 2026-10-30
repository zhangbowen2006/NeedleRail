import test from 'node:test';
import assert from 'node:assert/strict';
import {compile_json} from '../_build/js/release/build/bridge/bridge.js';
const cross=(a,b)=>a[0]*b[1]-a[1]*b[0];
const sub=(a,b)=>[a[0]-b[0],a[1]-b[1]];
function inside(p,rings){
  let odd=false;
  for(const ring of rings)for(let i=0;i<ring.length;i++){
    const a=ring[i],b=ring[(i+1)%ring.length];
    if(Math.abs(cross(sub(b,a),sub(p,a)))<1e-7 && p[0]>=Math.min(a[0],b[0])-1e-8 && p[0]<=Math.max(a[0],b[0])+1e-8 && p[1]>=Math.min(a[1],b[1])-1e-8 && p[1]<=Math.max(a[1],b[1])+1e-8)return true;
    if((a[1]>p[1])!==(b[1]>p[1]) && p[0]<(b[0]-a[0])*(p[1]-a[1])/(b[1]-a[1])+a[0])odd=!odd;
  }
  return odd;
}
// Partition the needle segment at every polygon boundary crossing. Testing the
// midpoint of each open subinterval checks the whole segment, not just endpoints.
function contained(a,b,rings){
  if(!inside(a,rings)||!inside(b,rings))return false;
  const v=sub(b,a),ts=[0,1],vv=v[0]*v[0]+v[1]*v[1];
  if(!vv)return true;
  for(const ring of rings)for(let i=0;i<ring.length;i++){
    const c=ring[i],d=ring[(i+1)%ring.length],w=sub(d,c),q=sub(c,a),den=cross(v,w);
    if(Math.abs(den)>1e-9){
      const t=cross(q,w)/den,u=cross(q,v)/den;
      if(t>0&&t<1&&u>=0&&u<=1)ts.push(t);
    }else if(Math.abs(cross(q,v))<1e-8){
      for(const p of [c,d]){const z=sub(p,a),t=(z[0]*v[0]+z[1]*v[1])/vv;if(t>0&&t<1)ts.push(t);}
    }
  }
  ts.sort((x,y)=>x-y);
  return ts.slice(1).every((t,i)=>{const m=(t+ts[i])/2;return inside([a[0]+v[0]*m,a[1]+v[1]*m],rings);});
}
test('independent oracle detects a segment crossing a hole despite valid endpoints',()=>{
  assert.equal(contained([-90,0],[90,0],[[[-100,-100],[100,-100],[100,100],[-100,100]],[[-10,-10],[10,-10],[10,10],[-10,10]]]),false);
});
test('entire sewing segments stay in concave, slanted, multi-hole and nested fills',()=>{
  const fixtures=[
    [[[-180,-150],[180,-150],[180,-20],[60,-20],[60,160],[-180,160]],[[-100,-80],[-40,-80],[-40,20],[-100,20]],[[-150,80],[-110,80],[-110,120],[-150,120]]],
    [[[-200,0],[0,-180],[200,0],[0,180]],[[-40,0],[0,-40],[40,0],[0,40]]],
    [[[-180,-180],[180,-180],[180,180],[-180,180]],[[-100,-100],[100,-100],[100,100],[-100,100]],[[-30,-30],[30,-30],[30,30],[-30,30]]]
  ];
  for(const rings of fixtures)for(const spacing of [3,8,17]){
    const compile=r=>JSON.parse(compile_json(JSON.stringify({width:1000,height:1000,max_step:25,objects:[{kind:'fill',thread:0,spacing,rings:r}]})));
    const out=compile(rings);assert.equal(out.error,undefined);
    let prev=[0,0];
    for(const c of out.report.commands){const next=[c.x,c.y];if(c.kind==='stitch')assert.ok(contained(prev,next,rings),JSON.stringify({prev,next,rings}));prev=next;}
    assert.deepEqual(compile(rings.map(r=>r.toReversed())).report.commands,out.report.commands);
  }
});
