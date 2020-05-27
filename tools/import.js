// Copyright (c) Jérémie N'gadi
//
// All rights reserved.
//
// Even if 'All rights reserved' is very clear :
//
//   You shall not use any piece of this software in a commercial product / service
//   You shall not resell this software
//   You shall not provide any facility to install this particular software in a commercial product / service
//   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/es_extended
//   This copyright should appear in every part of the project code

const fs       = require('fs');
const parseXML = require('xml2js').parseString;

function copyFile(src, dest) {
  fs.createReadStream(src).pipe(fs.createWriteStream(dest));
}

function toUnsigned(value) {
  return value >>> 0;
}

function toSigned(value, nbit = 32) {
  value = value << 32 - nbit;
  value = value >> 32 - nbit;
  return value;
}

function joaat(key){

  var keyLowered = key.toLowerCase();
  var length = keyLowered.length;
  var hash, i;

  for (hash = i = 0; i < length; i++) {
    hash += keyLowered.charCodeAt(i);
    hash += (hash <<  10);
    hash ^= (hash >>> 6);
  }

  hash += (hash <<  3);
  hash ^= (hash >>> 11);
  hash += (hash <<  15);

  return toSigned(hash);

}

if(process.argv[2] === 'meta') {

  const metas              = fs.readdirSync(__dirname + '/data/meta');
  const seen               = [];
  const ammoData           = [];
  const weaponData         = [];
  const componentData      = [];
  const weaponizedVehicles = [];
  const entities           = [];

  for(let i=0; i<metas.length; i++) {

    const xml = fs.readFileSync(__dirname + '/data/meta/' + metas[i]);

    parseXML(xml, (err, meta) => {

      if(err)
        return;

      if(typeof meta.CWeaponInfoBlob !== 'undefined') {

        let weaponInfos = [];

        for(let j=0; j<meta.CWeaponInfoBlob.Infos[0].Item.length; j++)
          if(meta.CWeaponInfoBlob.Infos[0].Item[j].Infos)
            for(let k=0; k<meta.CWeaponInfoBlob.Infos[0].Item[j].Infos.length; k++)
              weaponInfos = weaponInfos.concat(meta.CWeaponInfoBlob.Infos[0].Item[j].Infos[k].Item);


        for(let j=0; j<weaponInfos.length; j++) {

          if(weaponInfos[j]) {

            const nameHash = weaponInfos[j].Name[0];
            const hash     = joaat(nameHash.toLowerCase());

            entities.push(nameHash.toLowerCase());

            if(seen.indexOf(nameHash) === -1) {

              seen.push(nameHash);

              if(weaponInfos[j].$.type.match('CAmmo')) {

                const max = parseInt(weaponInfos[j].AmmoMax[0].$.value, 10);

                const entry = {nameHash, hash, max};

                ammoData.push(entry);

              }

              if(weaponInfos[j].$.type === 'CWeaponInfo') {

                let components       = [];
                const clipSize       = (weaponInfos[j].ClipSize && weaponInfos[j].ClipSize[0] && weaponInfos[j].ClipSize[0].$ && weaponInfos[j].ClipSize[0].$.value) ? parseInt(weaponInfos[j].ClipSize[0].$.value, 10) : undefined;
                const group          = weaponInfos[j].Group[0];
                const model          = weaponInfos[j].Model[0];
                const ammo           = weaponInfos[j].AmmoInfo[0].$.ref || null;
                const gxtName        = weaponInfos[j].HumanNameHash[0];
                const gxtDescription = gxtName.replace('WT_', 'WTD_');

                if(weaponInfos[j].AttachPoints[0] !== '') {

                  for(let k=0; k<weaponInfos[j].AttachPoints.length; k++) {

                    const items = weaponInfos[j].AttachPoints[k].Item;

                    for(let l=0; l<items.length; l++) {

                      const attachBone = items[l].AttachBone[0];
                      const cItems     = items[l].Components.map(e => e.Item);

                      for(let m=0; m<cItems.length; m++) {

                        const componentEntries = cItems[m].map(e => ({
                          nameHash  : e.Name[0],
                          hash      : joaat(e.Name[0].toLowerCase()),
                          isDefault : (e.Default[0].$.value === 'true') ? true : false,
                          attachBone: attachBone,
                        }));

                        components = components.concat(componentEntries);

                      }
                    }

                  }

                }

                const entry = {nameHash, hash, clipSize, group, model, ammo, gxtName, gxtDescription, components};

                weaponData.push(entry);

              }

            }
          }

        }

      }

      if(typeof meta.CWeaponComponentInfoBlob !== 'undefined') {

        let componentInfos = [];

        for(let j=0; j<meta.CWeaponComponentInfoBlob.Infos[0].Item.length; j++)
          componentInfos = componentInfos.concat(meta.CWeaponComponentInfoBlob.Infos[0].Item[j]);

        for(let j=0; j<componentInfos.length; j++) {

          const nameHash = componentInfos[j].Name[0];
          const hash     = joaat(nameHash.toLowerCase());

          entities.push(nameHash.toLowerCase());

          if(seen.indexOf(nameHash) === -1) {

            seen.push(nameHash);

            const type           = componentInfos[j].$.type;
            const model          = componentInfos[j].Model[0];
            const clipSize       = (type === 'CWeaponComponentClipInfo') ? parseInt(componentInfos[j].ClipSize[0].$.value, 10) : undefined;
            const gxtName        = componentInfos[j].LocName[0];
            const gxtDescription = componentInfos[j].LocDesc[0];

            const entry = {nameHash, hash, type, model, clipSize, gxtName, gxtDescription};

            componentData.push(entry);

          }
        }

      }

      if(typeof meta.CHandlingDataMgr !== 'undefined') {


        for(let i=0; i<meta.CHandlingDataMgr.HandlingData.length; i++) {

          let item = meta.CHandlingDataMgr.HandlingData[i].Item;

          for(let j=0; j<item.length; j++) {

            const vehicleName = item[j].handlingName instanceof Array ? item[j].handlingName[0] : item[j].handlingName;

            entities.push(vehicleName.toLowerCase());

            if(typeof item[j].SubHandlingData !== 'undefined') {

              const subHandlingData = item[j].SubHandlingData;

              for(let k=0; k<subHandlingData.length; k++) {

                const sub = subHandlingData[k];

                for(let l=0; l<sub.Item.length; l++) {

                  if(sub.Item[l].$.type === 'CVehicleWeaponHandlingData') {


                    const entry = {
                      nameHash: vehicleName,
                      hash: joaat(vehicleName),
                      weapons: []
                    };

                    for(let m = 0; m<sub.Item[l].uWeaponHash.length; m++) {
                      const uWeaponHash = sub.Item[l].uWeaponHash[m];
                      entry.weapons = uWeaponHash.Item.filter(e => e !== '');
                    }

                    weaponizedVehicles.push(entry);

                  }

                }

              }

            }

          }
        }

      }

    });

  }

  fs.writeFileSync(__dirname + '/data/ammo.json'      ,          JSON.stringify(ammoData,           null, 2));
  fs.writeFileSync(__dirname + '/data/weapons.json'   ,          JSON.stringify(weaponData,         null, 2));
  fs.writeFileSync(__dirname + '/data/weapon_components.json',   JSON.stringify(componentData,      null, 2));
  fs.writeFileSync(__dirname + '/data/weaponized_vehicles.json', JSON.stringify(weaponizedVehicles, null, 2));;
}

const weapons      = require(__dirname + '/data/weapons.json');
const weaponsExtra = require(__dirname + '/data/weapons_extra.json');
const components   = require(__dirname + '/data/weapon_components.json');

for(let i=0; i<weapons.length; i++) {

  const weapon = weapons[i];
  const extra  = weaponsExtra.nameHash[weapon.nameHash] || weaponsExtra.nameHash.default;

  for(let k in extra) {
    weapon[k] = extra[k];
  }

}

fs.writeFileSync(__dirname + '/../data/weapons.json'          , JSON.stringify(weapons,    null, 2));
fs.writeFileSync(__dirname + '/../data/weapon_components.json', JSON.stringify(components, null, 2));
