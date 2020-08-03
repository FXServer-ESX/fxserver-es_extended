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

(() => {

  class ESXWrapper {

    constructor() {

      this.resName = window.GetParentResourceName ? GetParentResourceName() : 'es_extended';

      window.addEventListener('keydown',     e => this.onKeyDown(e));
      window.addEventListener('keyup',       e => this.onKeyUp(e));
      window.addEventListener('mouseup',     e => this.onMouseUp(e));
      window.addEventListener('mousedown',   e => this.onMouseDown(e));
      // window.addEventListener('mousemove',   e => this.onMouseMove(e)); We'll spam GetNuiCursorPosition() instead
      window.addEventListener('mousewheel',  e => this.onMouseWheel(e));
      window.addEventListener('contextmenu', e => this.onContextMenu(e));

      window.NUICallback = (name, data = {}, asJSON = false) => this.NUICallback(name, data, asJSON);
      
    }

    postFrameMessage(msg) {
      
      if(window.__ESXROOT__)
        window.__ESXROOT__.postFrameMessage('__root__', msg);
      else
        window.parent.postMessage({...msg, __esxinternal: true}, '*');
    }

    async NUICallback(name, data = {}, asJSON = false) {

      const res = await fetch('http://' + this.resName + '/' + name, {
        method: 'POST',
        headers: {
          'Accept'      : 'application/json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
      });

      if(asJSON)
        return res.json();
      else
        return res.text();

    }

    onKeyDown(e) {
      this.postFrameMessage({action: 'key:down', args: [e.keyCode]});
    }

    onKeyUp(e) {
      this.postFrameMessage({action: 'key:up', args: [e.keyCode]});
    }

    onMouseDown(e) {
      this.postFrameMessage({action: 'mouse:down', args: [e.button]});
    }

    onMouseUp(e) {
      this.postFrameMessage({action: 'mouse:up', args: [e.button]});
    }

    onMouseMove(e) {
      this.postFrameMessage({action: 'mouse:move', args: [e.screenX, e.screenY]});
    }

    onMouseWheel(e) {
      this.postFrameMessage({action: 'mouse:wheel', args: [(e.wheelDelta > 0 ? 1 : -1)]});
    }

    onContextMenu(e) {
      this.postFrameMessage({action: 'context', args: []});
    }

  }

  window.__ESXWRAPPER__ = window.__ESXWRAPPER__ || new ESXWrapper();

})()
