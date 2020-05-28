<!--
 Copyright (c) Jérémie N'gadi

 All rights reserved.

 Even if 'All rights reserved' is very clear :

   You shall not use any piece of this software in a commercial product / service
   You shall not resell this software
   You shall not provide any facility to install this particular software in a commercial product / service
   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/es_extended
   This copyright should appear in every part of the project code
-->

<script>

	import { onMount, beforeUpdate } from 'svelte';

	export let float = 'left|top';

	export let title = 'Untitled ESX Menu';

	export let items  = [];
	export let _items = [];

	window.addEventListener('message', e => {

		const msg = e.data;

		switch(msg.action) {

			case 'set' : {

				float = msg.data.float || 'left|top';
				title = msg.data.title || 'Untitled ESX Menu';
				items = msg.data.items || [];

				break;
			}

			case 'set_item' : {

				items[msg.index][msg.prop] = msg.val;
				items = [...items];

				break;
			}

			default: break;
		}

	});

  const proxifyItems = () => {

		_items.length = 0;

    for(let i=0; i<items.length; i++) {

      ((i) => {

        _items[i] = new Proxy(items[i], {

          get: (obj, prop) => {
            return obj[prop];
          },

          set: (obj, prop, val) => {
            obj[prop] = val;
            window.parent.postMessage({action: 'item.change', index: i, prop, val}, '*');
            return true;
          },

          has: (obj, prop) => {
            return obj[prop] !== undefined;
          },

          ownKeys: (obj) => {
            return Object.keys(obj);
          }

        });

      })(i);

		}

		_items = [..._items];

  }

	onMount(() => {
		window.parent.postMessage({action: 'ready'}, '*');
	});

	beforeUpdate(proxifyItems);

	const onItemClick = (e, item, index) => {
		window.parent.postMessage({action: 'item.click', index}, '*');
	}

	const onSliderWheel = (e, item, index) => {

		if((e.deltaY > 0) && (item.value > item.min))
			item.value--;
		else if((e.deltaY < 0) && (item.value < item.max))
			item.value++;
	}

</script>

<main class="{float.split('|').map(e => 'float-' + e).join(' ')}">
	<main-wrap>

		<item class="title">{title}</item>

		{#each _items as item, i}

			{#if item.visible}

				{#if item.type === 'default' || item.type === 'button'}
					<item class="{item.type === 'button' ? 'button' : ''}" on:click={e => onItemClick(e, item, i)}>{item.label}</item>
				{/if}

				{#if item.type === 'slider'}
					<item class="slider" on:click={e => onItemClick(e, item, i)} on:wheel={e => onSliderWheel(e, item, i)}>
						<div>{item.label}</div>
						<div><input type="range" bind:value={item.value} min={item.min} max={item.max}></div>
					</item>
				{/if}

				{#if item.type === 'check'}
					<item class="check" on:click={e => {onItemClick(e, item, i); item.value = !item.value}} >
						{item.label} <input type="checkbox" bind:checked={item.value}/>
					</item>
				{/if}

				{#if item.type === 'text'}
					<item class="text" on:click={e => onItemClick(e, item, i)}>
						<div>{item.label}</div>
						<div><input type="text" bind:value={item.value} placeholder={item.placeholder || ''} autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"/></div>
					</item>
				{/if}

			{/if}

		{/each}
	</main-wrap>
</main>

<style>

	main > main-wrap {
		display: flex;
		position: absolute;
		border-left: 0;
		background-color: rgba(0, 0, 0, 0.9);
		padding: 15px 10px;
		font-size: 1.1em;
		user-select: none;
		flex-direction: column;
		border-radius: 10px;
    min-width: 280px;
    max-width: calc(100vh - 50px);
    max-height: calc(100vh - 50px);
    overflow-y: auto;
  }

	main > main-wrap::-webkit-scrollbar-track {
		box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
		border-radius: 10px;
		background-color: rgba(0,0,0,.1);
	}

	main > main-wrap::-webkit-scrollbar {
		width: 10px;
		background-color: transparent;
	}

	main > main-wrap::-webkit-scrollbar-thumb {
		border-radius: 10px;
		background-color: rgba(255, 255, 255, 0.75);
	}


	main.float-left > main-wrap {
		left: 10px;
	}

	main.float-right > main-wrap {
		right: 10px;
	}

	main.float-top > main-wrap {
		top: 10px;
	}

	main.float-botttom > main-wrap {
		bottom: 10px;
	}

  main.float-center > main-wrap {
    left: 50%;
    transform: translateX(-50%);
  }

  main.float-middle > main-wrap {
    top: 50%;
    transform: translateY(-50%);
  }

  main.float-center.float-middle > main-wrap {
    transform: translate(-50%, -50%);
  }

	item {
		padding: 14px;
		border-radius: 10px;
		cursor: pointer;
		color: rgba(255, 255, 255, 0.6);
		text-align: center;
	}

	item input:focus {
		outline: none;
	}

	item > div {
		padding-bottom: 5px;
	}

	item:hover {
		background-color: rgba(255, 255, 255, 0.07);
	}

	item.title {
    text-align: center;
    border-bottom: 1px solid rgba(109, 109, 109, 0.25);
    border-radius: 0;
    padding-bottom: 30px;
    margin-bottom: 20px;
	}

	item.title:hover {
		background-color: unset;
		cursor: default;
	}

	item.button {
		text-decoration: underline;
		text-align: center;
	}

	item.slider {
		width: calc(100% - 30px);
	}

	item.slider input {
		width: calc(100% - 10px);
		background-color: rgba(0, 0, 0, 0.25);
		-webkit-appearance: none;
	}

	item.slider > div:nth-child(1) {
		text-align: center;
	}

	item.slider input::-webkit-slider-thumb {
		-webkit-appearance: none;
		appearance: none;
		width: 16px;
		height: 16px;
		border-radius: 5px;
		background: rgba(255, 255, 255, 0.411);
		cursor: pointer;
	}

	item.check {
		display: flex;
    flex-direction: row;
		justify-content: space-between;
    align-items: center;
	}

	item.check input {
		-webkit-appearance: none;
    border-radius: 4px;
    height: 24px;
    width: 24px;
    background: rgba(0, 0, 0, 0.25);
    border: 1px solid rgba(255, 255, 255, 0.25);
    cursor: pointer;
	}

	item.check input:checked::after {
		display: block;
    content: 'x';
    font-weight: bold;
    font-size: 1.75em;
    text-align: center;
    margin-top: -4px;
    color: rgba(255, 255, 255, 0.79);
	}

	item.text input {
		width: calc(100% - 5px);
    height: 1em;
    padding: 5px;
    font-size: 1em;
    background-color: rgba(0, 0, 0, 0.59);
    border: 1px solid rgba(210, 210, 210, 0.25);
		color: rgba(191, 191, 191, 0.75);
	}

	item.text > div:nth-child(1) {
		text-align: center;
	}

</style>
