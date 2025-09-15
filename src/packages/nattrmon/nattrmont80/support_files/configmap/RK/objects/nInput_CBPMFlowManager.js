/**
 * <odoc>
 * <key>nattrmon.nInput_CBPMFlowManager(aMap) : nInput</key>
 * aMap is composed of:\
 *  - keys (a key string or an array of keys for an AF object)\
 *  - chKeys (a channel name for the keys of AF objects)\
 *  - attrTemplate (a template for the name of the attribute)\
 *  - extra (an array of extra map values to include from the chKeys channel values)\
 * \
 * </odoc>
 */
var nInput_CBPMFlowManager = function (aMap, attributePrefix) {
   if (isUnDef(getOPackPath("OpenCli"))) {
      throw "OpenCli opack not installed.";
   }

   if (isMap(aMap)) {
      this.params = aMap;
      // If keys is not an array make it an array.
      if (!(isArray(this.params.keys))) {
         this.params.keys = [this.params.keys];
      } 

      if (isUnDef(this.params.attrTemplate)) this.params.attrTemplate = "RAID/CBPM Flow Manager";
   } 
    
   nInput.call(this, this.input);
}
inherit(nInput_CBPMFlowManager, nInput);

nInput_CBPMFlowManager.prototype.__get = function (aKey, aExtra) {
   var ret = {};

   var fnClass = m => {
      var r = $from(Object.keys(m.Services))
          .starts("wedo.cbpm.services.flow.FlowManager")

      if (r.none()) return __
      return r.at(0)
  }
   
   try {
      var obj;
      var parent = this;
      
      if (isBoolean(parent.useCache)) {
         var res = $cache("nattrmon::" + aKey).get({ op: "StatusReport", args: {} });
         if (isMap(res) && isDef(res.__error)) throw res.__error;
         obj = res;
      } else {
         nattrmon.useObject(aKey, function (s) {
            try {
               obj = s.exec("StatusReport", {});
            } catch (e) {
               logErr("Error while retrieving status report using '" + aKey + "': " + e.message);
               throw e;
            }
         });
      }

      var fnC = fnClass(obj)
      if (isDef(obj.Services) &&
          isDef(fnC) &&
          isDef(obj.Services[fnC]["CBPM.FlowManager"])) {
            obj = obj.Services[fnC]["CBPM.FlowManager"];
            delete obj.RunningFlows;
            traverse(obj, (aK, aV, aP, aO) => { if (aK == "ClassName") delete aO[aK] });
            obj = ow.obj.flatMap(obj);
      } else {
         obj = {};
      }

   } catch (e) {
      logErr("Error while retrieving status report using '" + aKey + "': " + e.message);
   }

   ret = merge({ Key: aKey }, obj);

   return ret;
}

nInput_CBPMFlowManager.prototype.input = function (scope, args) {
   var res = {};
   var arr = [];

   if (isDef(this.params.chKeys)) this.params.keys = $stream($ch(this.params.chKeys).getKeys()).map("key").toArray().sort();

   for (var i in this.params.keys) {
      var extra = {};
      if (isDef(this.params.chKeys)) {
         var value = $ch(this.params.chKeys).get({ key: this.params.keys[i] });
         if (isDef(value)) {
            for (var j in this.params.extra) {
               if (isDef(value[this.params.extra[j]])) extra[this.params.extra[j]] = value[this.params.extra[j]];
            }
         }
      }
      arr.push(this.__get(this.params.keys[i], extra));
   }

   res[templify(this.params.attrTemplate)] = arr;
   return res;
}