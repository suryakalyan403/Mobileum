/**
 * <odoc>
 * <key>nattrmon.nInput_RAIDStatus_DB(aMap) : nInput</key>
 * You can create an input to check for sessions using a map composed of:\
 *    - keys (a key string or an array of keys for an AF object)\
 *    - chKeys (a channel name for the keys of AF objects)\
 *    - attrTemplate (a string template)\
 * \
 * </odoc>
 */
var nInput_RAIDStatus_DB = function (aMap) {
    if (isUnDef(getOPackPath("OpenCli"))) {
        throw "OpenCli opack not installed.";
    }

    if (isObject(aMap)) {
        this.params = aMap;

        // If keys is not an array make it an array.
        if (!(isArray(this.params.keys))) this.params.keys = [this.params.keys];
    }

    if (isDef(this.attributePrefix)) {
        this.params.attrTemplate = this.attributePrefix;
    }
    if (isUnDef(this.params.attrTemplate)) {
        this.params.attrTemplate = "RAID/{{name}} DB connections";
    }

    nInput.call(this, this.input);
}
inherit(nInput_RAIDStatus_DB, nInput);

nInput_RAIDStatus_DB.prototype.__getData = function (aKey, scope) {
    var retSes = {};
    var ses, parseResult = false;

    try {
        var parent = this;

        var fnClass = m => {
            var r = $from(Object.keys(m.Services))
                .starts("wedo.jaf.services.database.ConnectionManagerBase")
      
            if (r.none()) return __
            return r.at(0)
        }

        if (isDef(aKey)) {
            if (isBoolean(parent.params.useCache) && parent.params.useCache) {
                var res = $cache("nattrmon::" + aKey).get({ op: "StatusReport", args: {} });
                var fnC = fnClass(res)
                if (isMap(res) && isDef(res.__error)) throw res.__error;
                if (isMap(res) && isDef(res.Services) && isDef(fnC)) {
                    res = res.Services[fnC];
                    parseResult = true;
                    ses = res;
                } else {
                    logErr("Error while retrieving connection manager base data using '" + aKey);
                }
            } else {
                nattrmon.useObject(aKey, s => {
                    try {
                        ses = s.exec("StatusReport", {});
                        var fnC = fnClass(ses)
                        if (isMap(ses) && isDef(ses.Services) && isDef(ses.Services[fnC])) {
                            ses = ses.Services[fnC];
                            parseResult = true;
                            return true;
                        } else {
                            return false;
                        }
                    } catch (e1) {
                        logErr("Error while retrieving connection manager base data using '" + aKey + "': " + e1.message);
                        return false;
                    }
                });
            }
        } else {
            try {
                ses = s.exec("StatusReport", {})
                var fnC = fnClass(ses)
                if (isMap(ses) && isDef(ses.Services) && isDef(fnC)) {
                    ses = ses.Services[fnC];
                    parseResult = true;
                }
            } catch (e2) {
                logErr("Error while retrieving connection manager base data: " + e2.message);
            }
        }

        if (parseResult) {
            retSes = $from(ses).select(r => {
                return {
                    "Name": aKey,
                    "DB": r._key,
                    "Connections": r.Connections,
                    "Active": r.Active,
                    "AvgTimeForConnection": r.AverageTimeForConns,
                    "MaxConnections": r.MaxConnections,
                    "WaitListLength": r.WaitList.length,
                    "Fetches": r.Fetches,
                    "Total": r.Total,
                    "InUseLength": r.InUse.length,
                    "AverageWait": r.AverageWait,
                    "CallersGaveUp": r["N.CallerGaveUp"],
                    "PoolOutOfConnections": r["N.PoolOutOfConns"]
                };
            });
        } else {
            throw "can't parse results";
        }
    } catch (e3) {
        logErr("Error while retrieving db connections data using '" + aKey + "': " + e3.message);
    }

    return retSes;
};

nInput_RAIDStatus_DB.prototype.input = function (scope, args) {
    var res = {};
    var arr = [];

    if (isDef(this.params.chKeys)) this.params.keys = $stream($ch(this.params.chKeys).getKeys()).map("key").toArray();

    for (var i in this.params.keys) {
        arr = arr.concat(this.__getData(this.params.keys[i], scope));
    }

    res[templify(this.params.attrTemplate)] = arr;
    return res;
};