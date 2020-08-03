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

  class ESXRoot {

    constructor() {

      this.frames  = {};
      this.resName = GetParentResourceName();

      window.addEventListener('message', e => {
        
        // Find which frame sent message
        for(let name in this.frames) {
          if(this.frames[name].iframe.contentWindow === e.source) {
            this.postFrameMessage(name, e.data);
            return;
          }
        }

        // Not a frame ? Coming from client script
        this.onMessage(e.data);

      });

      this.NUICallback('nui_ready');

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

    createFrame(name, url, visible = true) {

      const frame       = document.createElement('div');
      const iframe      = document.createElement('iframe');

      frame.appendChild(iframe);

      iframe.src        = url;
      this.frames[name] = {frame, iframe};

      this.frames[name].iframe.addEventListener('message', e => this.onFrameMessage(name, e.data));
      this.frames[name].frame.style.pointerEvents = 'none';

      document.querySelector('#frames').appendChild(frame);

      if(!visible)
        this.hideFrame(name);

      this.frames[name].iframe.contentWindow.addEventListener('DOMContentLoaded', () => {
        this.NUICallback('frame_load', {name});
      }, true);

      return this.frames[name];

    }

    destroyFrame(name) {
      this.frames[name].iframe.remove();
      this.frames[name].frame.remove();
      delete this.frames[name];
    }

    showFrame(name) {
      this.frames[name].frame.style.display = 'block';
    }

    hideFrame(name) {
      this.frames[name].frame.style.display = 'none';
    }

    focusFrame(name) {

      for(let k in this.frames) {

        if(k === name)
          this.frames[k].frame.style.pointerEvents = 'all';
        else
          this.frames[k].frame.style.pointerEvents = 'none';
      }

      this.frames[name].iframe.contentWindow.focus();

    }

    onMessage(msg) {

      if(msg.target) {

        if(this.frames[msg.target])
          this.frames[msg.target].iframe.contentWindow.postMessage(msg.data);
        else
          console.error('[esx:nui] cannot find frame : ' + msg.target);

      } else {

        switch(msg.action) {

          case 'create_frame' : {
            this.createFrame(msg.name, msg.url, msg.visible);
            break;
          }

          case 'destroy_frame' : {
            this.destroyFrame(msg.name);
            break;
          }

          case 'focus_frame' : {
            this.focusFrame(msg.name);
            break;
          }

          case 'show_frame' : {
            this.showFrame(msg.name);
            break;
          }

          case 'hide_frame' : {
            this.hideFrame(msg.name);
            break;
          }

          default: break;
        }

      }


    }

    postFrameMessage(name, msg) {
      this.NUICallback('frame_message', {name, msg})
    }

  }

  window.__ESXROOT__ = window.__ESXROOT__ || new ESXRoot();

})();
