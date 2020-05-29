
(function(l, r) { if (l.getElementById('livereloadscript')) return; r = l.createElement('script'); r.async = 1; r.src = '//' + (window.location.host || 'localhost').split(':')[0] + ':35729/livereload.js?snipver=1'; r.id = 'livereloadscript'; l.getElementsByTagName('head')[0].appendChild(r) })(window.document);
var app = (function () {
    'use strict';

    function noop() { }
    function add_location(element, file, line, column, char) {
        element.__svelte_meta = {
            loc: { file, line, column, char }
        };
    }
    function run(fn) {
        return fn();
    }
    function blank_object() {
        return Object.create(null);
    }
    function run_all(fns) {
        fns.forEach(run);
    }
    function is_function(thing) {
        return typeof thing === 'function';
    }
    function safe_not_equal(a, b) {
        return a != a ? b == b : a !== b || ((a && typeof a === 'object') || typeof a === 'function');
    }
    function null_to_empty(value) {
        return value == null ? '' : value;
    }

    function append(target, node) {
        target.appendChild(node);
    }
    function insert(target, node, anchor) {
        target.insertBefore(node, anchor || null);
    }
    function detach(node) {
        node.parentNode.removeChild(node);
    }
    function destroy_each(iterations, detaching) {
        for (let i = 0; i < iterations.length; i += 1) {
            if (iterations[i])
                iterations[i].d(detaching);
        }
    }
    function element(name) {
        return document.createElement(name);
    }
    function text(data) {
        return document.createTextNode(data);
    }
    function space() {
        return text(' ');
    }
    function empty() {
        return text('');
    }
    function listen(node, event, handler, options) {
        node.addEventListener(event, handler, options);
        return () => node.removeEventListener(event, handler, options);
    }
    function attr(node, attribute, value) {
        if (value == null)
            node.removeAttribute(attribute);
        else if (node.getAttribute(attribute) !== value)
            node.setAttribute(attribute, value);
    }
    function set_custom_element_data(node, prop, value) {
        if (prop in node) {
            node[prop] = value;
        }
        else {
            attr(node, prop, value);
        }
    }
    function to_number(value) {
        return value === '' ? undefined : +value;
    }
    function children(element) {
        return Array.from(element.childNodes);
    }
    function set_input_value(input, value) {
        if (value != null || input.value) {
            input.value = value;
        }
    }
    function custom_event(type, detail) {
        const e = document.createEvent('CustomEvent');
        e.initCustomEvent(type, false, false, detail);
        return e;
    }

    let current_component;
    function set_current_component(component) {
        current_component = component;
    }
    function get_current_component() {
        if (!current_component)
            throw new Error(`Function called outside component initialization`);
        return current_component;
    }
    function beforeUpdate(fn) {
        get_current_component().$$.before_update.push(fn);
    }
    function onMount(fn) {
        get_current_component().$$.on_mount.push(fn);
    }

    const dirty_components = [];
    const binding_callbacks = [];
    const render_callbacks = [];
    const flush_callbacks = [];
    const resolved_promise = Promise.resolve();
    let update_scheduled = false;
    function schedule_update() {
        if (!update_scheduled) {
            update_scheduled = true;
            resolved_promise.then(flush);
        }
    }
    function add_render_callback(fn) {
        render_callbacks.push(fn);
    }
    let flushing = false;
    const seen_callbacks = new Set();
    function flush() {
        if (flushing)
            return;
        flushing = true;
        do {
            // first, call beforeUpdate functions
            // and update components
            for (let i = 0; i < dirty_components.length; i += 1) {
                const component = dirty_components[i];
                set_current_component(component);
                update(component.$$);
            }
            dirty_components.length = 0;
            while (binding_callbacks.length)
                binding_callbacks.pop()();
            // then, once components are updated, call
            // afterUpdate functions. This may cause
            // subsequent updates...
            for (let i = 0; i < render_callbacks.length; i += 1) {
                const callback = render_callbacks[i];
                if (!seen_callbacks.has(callback)) {
                    // ...so guard against infinite loops
                    seen_callbacks.add(callback);
                    callback();
                }
            }
            render_callbacks.length = 0;
        } while (dirty_components.length);
        while (flush_callbacks.length) {
            flush_callbacks.pop()();
        }
        update_scheduled = false;
        flushing = false;
        seen_callbacks.clear();
    }
    function update($$) {
        if ($$.fragment !== null) {
            $$.update();
            run_all($$.before_update);
            const dirty = $$.dirty;
            $$.dirty = [-1];
            $$.fragment && $$.fragment.p($$.ctx, dirty);
            $$.after_update.forEach(add_render_callback);
        }
    }
    const outroing = new Set();
    function transition_in(block, local) {
        if (block && block.i) {
            outroing.delete(block);
            block.i(local);
        }
    }

    const globals = (typeof window !== 'undefined' ? window : global);
    function mount_component(component, target, anchor) {
        const { fragment, on_mount, on_destroy, after_update } = component.$$;
        fragment && fragment.m(target, anchor);
        // onMount happens before the initial afterUpdate
        add_render_callback(() => {
            const new_on_destroy = on_mount.map(run).filter(is_function);
            if (on_destroy) {
                on_destroy.push(...new_on_destroy);
            }
            else {
                // Edge case - component was destroyed immediately,
                // most likely as a result of a binding initialising
                run_all(new_on_destroy);
            }
            component.$$.on_mount = [];
        });
        after_update.forEach(add_render_callback);
    }
    function destroy_component(component, detaching) {
        const $$ = component.$$;
        if ($$.fragment !== null) {
            run_all($$.on_destroy);
            $$.fragment && $$.fragment.d(detaching);
            // TODO null out other refs, including component.$$ (but need to
            // preserve final state?)
            $$.on_destroy = $$.fragment = null;
            $$.ctx = [];
        }
    }
    function make_dirty(component, i) {
        if (component.$$.dirty[0] === -1) {
            dirty_components.push(component);
            schedule_update();
            component.$$.dirty.fill(0);
        }
        component.$$.dirty[(i / 31) | 0] |= (1 << (i % 31));
    }
    function init(component, options, instance, create_fragment, not_equal, props, dirty = [-1]) {
        const parent_component = current_component;
        set_current_component(component);
        const prop_values = options.props || {};
        const $$ = component.$$ = {
            fragment: null,
            ctx: null,
            // state
            props,
            update: noop,
            not_equal,
            bound: blank_object(),
            // lifecycle
            on_mount: [],
            on_destroy: [],
            before_update: [],
            after_update: [],
            context: new Map(parent_component ? parent_component.$$.context : []),
            // everything else
            callbacks: blank_object(),
            dirty
        };
        let ready = false;
        $$.ctx = instance
            ? instance(component, prop_values, (i, ret, ...rest) => {
                const value = rest.length ? rest[0] : ret;
                if ($$.ctx && not_equal($$.ctx[i], $$.ctx[i] = value)) {
                    if ($$.bound[i])
                        $$.bound[i](value);
                    if (ready)
                        make_dirty(component, i);
                }
                return ret;
            })
            : [];
        $$.update();
        ready = true;
        run_all($$.before_update);
        // `false` as a special case of no DOM component
        $$.fragment = create_fragment ? create_fragment($$.ctx) : false;
        if (options.target) {
            if (options.hydrate) {
                const nodes = children(options.target);
                // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
                $$.fragment && $$.fragment.l(nodes);
                nodes.forEach(detach);
            }
            else {
                // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
                $$.fragment && $$.fragment.c();
            }
            if (options.intro)
                transition_in(component.$$.fragment);
            mount_component(component, options.target, options.anchor);
            flush();
        }
        set_current_component(parent_component);
    }
    class SvelteComponent {
        $destroy() {
            destroy_component(this, 1);
            this.$destroy = noop;
        }
        $on(type, callback) {
            const callbacks = (this.$$.callbacks[type] || (this.$$.callbacks[type] = []));
            callbacks.push(callback);
            return () => {
                const index = callbacks.indexOf(callback);
                if (index !== -1)
                    callbacks.splice(index, 1);
            };
        }
        $set() {
            // overridden by instance, if it has props
        }
    }

    function dispatch_dev(type, detail) {
        document.dispatchEvent(custom_event(type, Object.assign({ version: '3.20.1' }, detail)));
    }
    function append_dev(target, node) {
        dispatch_dev("SvelteDOMInsert", { target, node });
        append(target, node);
    }
    function insert_dev(target, node, anchor) {
        dispatch_dev("SvelteDOMInsert", { target, node, anchor });
        insert(target, node, anchor);
    }
    function detach_dev(node) {
        dispatch_dev("SvelteDOMRemove", { node });
        detach(node);
    }
    function listen_dev(node, event, handler, options, has_prevent_default, has_stop_propagation) {
        const modifiers = options === true ? ["capture"] : options ? Array.from(Object.keys(options)) : [];
        if (has_prevent_default)
            modifiers.push('preventDefault');
        if (has_stop_propagation)
            modifiers.push('stopPropagation');
        dispatch_dev("SvelteDOMAddEventListener", { node, event, handler, modifiers });
        const dispose = listen(node, event, handler, options);
        return () => {
            dispatch_dev("SvelteDOMRemoveEventListener", { node, event, handler, modifiers });
            dispose();
        };
    }
    function attr_dev(node, attribute, value) {
        attr(node, attribute, value);
        if (value == null)
            dispatch_dev("SvelteDOMRemoveAttribute", { node, attribute });
        else
            dispatch_dev("SvelteDOMSetAttribute", { node, attribute, value });
    }
    function set_data_dev(text, data) {
        data = '' + data;
        if (text.data === data)
            return;
        dispatch_dev("SvelteDOMSetData", { node: text, data });
        text.data = data;
    }
    function validate_each_argument(arg) {
        if (typeof arg !== 'string' && !(arg && typeof arg === 'object' && 'length' in arg)) {
            let msg = '{#each} only iterates over array-like objects.';
            if (typeof Symbol === 'function' && arg && Symbol.iterator in arg) {
                msg += ' You can use a spread to convert this iterable into an array.';
            }
            throw new Error(msg);
        }
    }
    function validate_slots(name, slot, keys) {
        for (const slot_key of Object.keys(slot)) {
            if (!~keys.indexOf(slot_key)) {
                console.warn(`<${name}> received an unexpected slot "${slot_key}".`);
            }
        }
    }
    class SvelteComponentDev extends SvelteComponent {
        constructor(options) {
            if (!options || (!options.target && !options.$$inline)) {
                throw new Error(`'target' is a required option`);
            }
            super();
        }
        $destroy() {
            super.$destroy();
            this.$destroy = () => {
                console.warn(`Component was already destroyed`); // eslint-disable-line no-console
            };
        }
        $capture_state() { }
        $inject_state() { }
    }

    /* src\App.svelte generated by Svelte v3.20.1 */

    const { Object: Object_1 } = globals;
    const file = "src\\App.svelte";

    function get_each_context(ctx, list, i) {
    	const child_ctx = ctx.slice();
    	child_ctx[15] = list[i];
    	child_ctx[16] = list;
    	child_ctx[17] = i;
    	return child_ctx;
    }

    // (120:3) {#if item.visible}
    function create_if_block(ctx) {
    	let t0;
    	let t1;
    	let t2;
    	let if_block3_anchor;
    	let if_block0 = (/*item*/ ctx[15].type === "default" || /*item*/ ctx[15].type === "button") && create_if_block_4(ctx);
    	let if_block1 = /*item*/ ctx[15].type === "slider" && create_if_block_3(ctx);
    	let if_block2 = /*item*/ ctx[15].type === "check" && create_if_block_2(ctx);
    	let if_block3 = /*item*/ ctx[15].type === "text" && create_if_block_1(ctx);

    	const block = {
    		c: function create() {
    			if (if_block0) if_block0.c();
    			t0 = space();
    			if (if_block1) if_block1.c();
    			t1 = space();
    			if (if_block2) if_block2.c();
    			t2 = space();
    			if (if_block3) if_block3.c();
    			if_block3_anchor = empty();
    		},
    		m: function mount(target, anchor) {
    			if (if_block0) if_block0.m(target, anchor);
    			insert_dev(target, t0, anchor);
    			if (if_block1) if_block1.m(target, anchor);
    			insert_dev(target, t1, anchor);
    			if (if_block2) if_block2.m(target, anchor);
    			insert_dev(target, t2, anchor);
    			if (if_block3) if_block3.m(target, anchor);
    			insert_dev(target, if_block3_anchor, anchor);
    		},
    		p: function update(ctx, dirty) {
    			if (/*item*/ ctx[15].type === "default" || /*item*/ ctx[15].type === "button") {
    				if (if_block0) {
    					if_block0.p(ctx, dirty);
    				} else {
    					if_block0 = create_if_block_4(ctx);
    					if_block0.c();
    					if_block0.m(t0.parentNode, t0);
    				}
    			} else if (if_block0) {
    				if_block0.d(1);
    				if_block0 = null;
    			}

    			if (/*item*/ ctx[15].type === "slider") {
    				if (if_block1) {
    					if_block1.p(ctx, dirty);
    				} else {
    					if_block1 = create_if_block_3(ctx);
    					if_block1.c();
    					if_block1.m(t1.parentNode, t1);
    				}
    			} else if (if_block1) {
    				if_block1.d(1);
    				if_block1 = null;
    			}

    			if (/*item*/ ctx[15].type === "check") {
    				if (if_block2) {
    					if_block2.p(ctx, dirty);
    				} else {
    					if_block2 = create_if_block_2(ctx);
    					if_block2.c();
    					if_block2.m(t2.parentNode, t2);
    				}
    			} else if (if_block2) {
    				if_block2.d(1);
    				if_block2 = null;
    			}

    			if (/*item*/ ctx[15].type === "text") {
    				if (if_block3) {
    					if_block3.p(ctx, dirty);
    				} else {
    					if_block3 = create_if_block_1(ctx);
    					if_block3.c();
    					if_block3.m(if_block3_anchor.parentNode, if_block3_anchor);
    				}
    			} else if (if_block3) {
    				if_block3.d(1);
    				if_block3 = null;
    			}
    		},
    		d: function destroy(detaching) {
    			if (if_block0) if_block0.d(detaching);
    			if (detaching) detach_dev(t0);
    			if (if_block1) if_block1.d(detaching);
    			if (detaching) detach_dev(t1);
    			if (if_block2) if_block2.d(detaching);
    			if (detaching) detach_dev(t2);
    			if (if_block3) if_block3.d(detaching);
    			if (detaching) detach_dev(if_block3_anchor);
    		}
    	};

    	dispatch_dev("SvelteRegisterBlock", {
    		block,
    		id: create_if_block.name,
    		type: "if",
    		source: "(120:3) {#if item.visible}",
    		ctx
    	});

    	return block;
    }

    // (122:4) {#if item.type === 'default' || item.type === 'button'}
    function create_if_block_4(ctx) {
    	let item;
    	let t_value = /*item*/ ctx[15].label + "";
    	let t;
    	let item_class_value;
    	let dispose;

    	function click_handler(...args) {
    		return /*click_handler*/ ctx[7](/*item*/ ctx[15], /*i*/ ctx[17], ...args);
    	}

    	const block = {
    		c: function create() {
    			item = element("item");
    			t = text(t_value);
    			attr_dev(item, "class", item_class_value = "" + (null_to_empty(/*item*/ ctx[15].type === "button" ? "button" : "") + " svelte-wfkbxe"));
    			add_location(item, file, 122, 5, 5137);
    		},
    		m: function mount(target, anchor, remount) {
    			insert_dev(target, item, anchor);
    			append_dev(item, t);
    			if (remount) dispose();
    			dispose = listen_dev(item, "click", click_handler, false, false, false);
    		},
    		p: function update(new_ctx, dirty) {
    			ctx = new_ctx;
    			if (dirty & /*_items*/ 4 && t_value !== (t_value = /*item*/ ctx[15].label + "")) set_data_dev(t, t_value);

    			if (dirty & /*_items*/ 4 && item_class_value !== (item_class_value = "" + (null_to_empty(/*item*/ ctx[15].type === "button" ? "button" : "") + " svelte-wfkbxe"))) {
    				attr_dev(item, "class", item_class_value);
    			}
    		},
    		d: function destroy(detaching) {
    			if (detaching) detach_dev(item);
    			dispose();
    		}
    	};

    	dispatch_dev("SvelteRegisterBlock", {
    		block,
    		id: create_if_block_4.name,
    		type: "if",
    		source: "(122:4) {#if item.type === 'default' || item.type === 'button'}",
    		ctx
    	});

    	return block;
    }

    // (126:4) {#if item.type === 'slider'}
    function create_if_block_3(ctx) {
    	let item;
    	let div0;
    	let t0_value = /*item*/ ctx[15].label + "";
    	let t0;
    	let t1;
    	let div1;
    	let input;
    	let input_min_value;
    	let input_max_value;
    	let dispose;

    	function input_change_input_handler() {
    		/*input_change_input_handler*/ ctx[8].call(input, /*item*/ ctx[15]);
    	}

    	function click_handler_1(...args) {
    		return /*click_handler_1*/ ctx[9](/*item*/ ctx[15], /*i*/ ctx[17], ...args);
    	}

    	function wheel_handler(...args) {
    		return /*wheel_handler*/ ctx[10](/*item*/ ctx[15], /*i*/ ctx[17], ...args);
    	}

    	const block = {
    		c: function create() {
    			item = element("item");
    			div0 = element("div");
    			t0 = text(t0_value);
    			t1 = space();
    			div1 = element("div");
    			input = element("input");
    			attr_dev(div0, "class", "svelte-wfkbxe");
    			add_location(div0, file, 127, 6, 5416);
    			attr_dev(input, "type", "range");
    			attr_dev(input, "min", input_min_value = /*item*/ ctx[15].min);
    			attr_dev(input, "max", input_max_value = /*item*/ ctx[15].max);
    			attr_dev(input, "class", "svelte-wfkbxe");
    			add_location(input, file, 128, 11, 5452);
    			attr_dev(div1, "class", "svelte-wfkbxe");
    			add_location(div1, file, 128, 6, 5447);
    			attr_dev(item, "class", "slider svelte-wfkbxe");
    			add_location(item, file, 126, 5, 5305);
    		},
    		m: function mount(target, anchor, remount) {
    			insert_dev(target, item, anchor);
    			append_dev(item, div0);
    			append_dev(div0, t0);
    			append_dev(item, t1);
    			append_dev(item, div1);
    			append_dev(div1, input);
    			set_input_value(input, /*item*/ ctx[15].value);
    			if (remount) run_all(dispose);

    			dispose = [
    				listen_dev(input, "change", input_change_input_handler),
    				listen_dev(input, "input", input_change_input_handler),
    				listen_dev(item, "click", click_handler_1, false, false, false),
    				listen_dev(item, "wheel", wheel_handler, false, false, false)
    			];
    		},
    		p: function update(new_ctx, dirty) {
    			ctx = new_ctx;
    			if (dirty & /*_items*/ 4 && t0_value !== (t0_value = /*item*/ ctx[15].label + "")) set_data_dev(t0, t0_value);

    			if (dirty & /*_items*/ 4 && input_min_value !== (input_min_value = /*item*/ ctx[15].min)) {
    				attr_dev(input, "min", input_min_value);
    			}

    			if (dirty & /*_items*/ 4 && input_max_value !== (input_max_value = /*item*/ ctx[15].max)) {
    				attr_dev(input, "max", input_max_value);
    			}

    			if (dirty & /*_items*/ 4) {
    				set_input_value(input, /*item*/ ctx[15].value);
    			}
    		},
    		d: function destroy(detaching) {
    			if (detaching) detach_dev(item);
    			run_all(dispose);
    		}
    	};

    	dispatch_dev("SvelteRegisterBlock", {
    		block,
    		id: create_if_block_3.name,
    		type: "if",
    		source: "(126:4) {#if item.type === 'slider'}",
    		ctx
    	});

    	return block;
    }

    // (133:4) {#if item.type === 'check'}
    function create_if_block_2(ctx) {
    	let item;
    	let t0_value = /*item*/ ctx[15].label + "";
    	let t0;
    	let t1;
    	let input;
    	let dispose;

    	function input_change_handler() {
    		/*input_change_handler*/ ctx[11].call(input, /*item*/ ctx[15]);
    	}

    	function click_handler_2(...args) {
    		return /*click_handler_2*/ ctx[12](/*item*/ ctx[15], /*i*/ ctx[17], ...args);
    	}

    	const block = {
    		c: function create() {
    			item = element("item");
    			t0 = text(t0_value);
    			t1 = space();
    			input = element("input");
    			attr_dev(input, "type", "checkbox");
    			attr_dev(input, "class", "svelte-wfkbxe");
    			add_location(input, file, 134, 19, 5709);
    			attr_dev(item, "class", "check svelte-wfkbxe");
    			add_location(item, file, 133, 5, 5599);
    		},
    		m: function mount(target, anchor, remount) {
    			insert_dev(target, item, anchor);
    			append_dev(item, t0);
    			append_dev(item, t1);
    			append_dev(item, input);
    			input.checked = /*item*/ ctx[15].value;
    			if (remount) run_all(dispose);

    			dispose = [
    				listen_dev(input, "change", input_change_handler),
    				listen_dev(item, "click", click_handler_2, false, false, false)
    			];
    		},
    		p: function update(new_ctx, dirty) {
    			ctx = new_ctx;
    			if (dirty & /*_items*/ 4 && t0_value !== (t0_value = /*item*/ ctx[15].label + "")) set_data_dev(t0, t0_value);

    			if (dirty & /*_items*/ 4) {
    				input.checked = /*item*/ ctx[15].value;
    			}
    		},
    		d: function destroy(detaching) {
    			if (detaching) detach_dev(item);
    			run_all(dispose);
    		}
    	};

    	dispatch_dev("SvelteRegisterBlock", {
    		block,
    		id: create_if_block_2.name,
    		type: "if",
    		source: "(133:4) {#if item.type === 'check'}",
    		ctx
    	});

    	return block;
    }

    // (139:4) {#if item.type === 'text'}
    function create_if_block_1(ctx) {
    	let item;
    	let div0;
    	let t0_value = /*item*/ ctx[15].label + "";
    	let t0;
    	let t1;
    	let div1;
    	let input;
    	let input_placeholder_value;
    	let t2;
    	let dispose;

    	function input_input_handler() {
    		/*input_input_handler*/ ctx[13].call(input, /*item*/ ctx[15]);
    	}

    	function click_handler_3(...args) {
    		return /*click_handler_3*/ ctx[14](/*item*/ ctx[15], /*i*/ ctx[17], ...args);
    	}

    	const block = {
    		c: function create() {
    			item = element("item");
    			div0 = element("div");
    			t0 = text(t0_value);
    			t1 = space();
    			div1 = element("div");
    			input = element("input");
    			t2 = space();
    			attr_dev(div0, "class", "svelte-wfkbxe");
    			add_location(div0, file, 140, 6, 5892);
    			attr_dev(input, "type", "text");
    			attr_dev(input, "placeholder", input_placeholder_value = /*item*/ ctx[15].placeholder || "");
    			attr_dev(input, "autocomplete", "off");
    			attr_dev(input, "autocorrect", "off");
    			attr_dev(input, "autocapitalize", "off");
    			attr_dev(input, "spellcheck", "false");
    			attr_dev(input, "class", "svelte-wfkbxe");
    			add_location(input, file, 141, 11, 5928);
    			attr_dev(div1, "class", "svelte-wfkbxe");
    			add_location(div1, file, 141, 6, 5923);
    			attr_dev(item, "class", "text svelte-wfkbxe");
    			add_location(item, file, 139, 5, 5825);
    		},
    		m: function mount(target, anchor, remount) {
    			insert_dev(target, item, anchor);
    			append_dev(item, div0);
    			append_dev(div0, t0);
    			append_dev(item, t1);
    			append_dev(item, div1);
    			append_dev(div1, input);
    			set_input_value(input, /*item*/ ctx[15].value);
    			append_dev(item, t2);
    			if (remount) run_all(dispose);

    			dispose = [
    				listen_dev(input, "input", input_input_handler),
    				listen_dev(item, "click", click_handler_3, false, false, false)
    			];
    		},
    		p: function update(new_ctx, dirty) {
    			ctx = new_ctx;
    			if (dirty & /*_items*/ 4 && t0_value !== (t0_value = /*item*/ ctx[15].label + "")) set_data_dev(t0, t0_value);

    			if (dirty & /*_items*/ 4 && input_placeholder_value !== (input_placeholder_value = /*item*/ ctx[15].placeholder || "")) {
    				attr_dev(input, "placeholder", input_placeholder_value);
    			}

    			if (dirty & /*_items*/ 4 && input.value !== /*item*/ ctx[15].value) {
    				set_input_value(input, /*item*/ ctx[15].value);
    			}
    		},
    		d: function destroy(detaching) {
    			if (detaching) detach_dev(item);
    			run_all(dispose);
    		}
    	};

    	dispatch_dev("SvelteRegisterBlock", {
    		block,
    		id: create_if_block_1.name,
    		type: "if",
    		source: "(139:4) {#if item.type === 'text'}",
    		ctx
    	});

    	return block;
    }

    // (118:2) {#each _items as item, i}
    function create_each_block(ctx) {
    	let if_block_anchor;
    	let if_block = /*item*/ ctx[15].visible && create_if_block(ctx);

    	const block = {
    		c: function create() {
    			if (if_block) if_block.c();
    			if_block_anchor = empty();
    		},
    		m: function mount(target, anchor) {
    			if (if_block) if_block.m(target, anchor);
    			insert_dev(target, if_block_anchor, anchor);
    		},
    		p: function update(ctx, dirty) {
    			if (/*item*/ ctx[15].visible) {
    				if (if_block) {
    					if_block.p(ctx, dirty);
    				} else {
    					if_block = create_if_block(ctx);
    					if_block.c();
    					if_block.m(if_block_anchor.parentNode, if_block_anchor);
    				}
    			} else if (if_block) {
    				if_block.d(1);
    				if_block = null;
    			}
    		},
    		d: function destroy(detaching) {
    			if (if_block) if_block.d(detaching);
    			if (detaching) detach_dev(if_block_anchor);
    		}
    	};

    	dispatch_dev("SvelteRegisterBlock", {
    		block,
    		id: create_each_block.name,
    		type: "each",
    		source: "(118:2) {#each _items as item, i}",
    		ctx
    	});

    	return block;
    }

    function create_fragment(ctx) {
    	let main;
    	let main_wrap;
    	let item0;
    	let t0;
    	let t1;
    	let item1;
    	let t2;
    	let main_items;
    	let main_class_value;
    	let each_value = /*_items*/ ctx[2];
    	validate_each_argument(each_value);
    	let each_blocks = [];

    	for (let i = 0; i < each_value.length; i += 1) {
    		each_blocks[i] = create_each_block(get_each_context(ctx, each_value, i));
    	}

    	const block = {
    		c: function create() {
    			main = element("main");
    			main_wrap = element("main-wrap");
    			item0 = element("item");
    			t0 = text(/*title*/ ctx[1]);
    			t1 = space();
    			item1 = element("item");
    			t2 = space();
    			main_items = element("main-items");

    			for (let i = 0; i < each_blocks.length; i += 1) {
    				each_blocks[i].c();
    			}

    			attr_dev(item0, "class", "title svelte-wfkbxe");
    			add_location(item0, file, 114, 2, 4927);
    			attr_dev(item1, "class", "titledivider svelte-wfkbxe");
    			add_location(item1, file, 115, 2, 4965);
    			set_custom_element_data(main_items, "class", "svelte-wfkbxe");
    			add_location(main_items, file, 116, 0, 5001);
    			set_custom_element_data(main_wrap, "class", "svelte-wfkbxe");
    			add_location(main_wrap, file, 112, 1, 4910);
    			attr_dev(main, "class", main_class_value = "" + (null_to_empty(/*float*/ ctx[0].split("|").map(func).join(" ")) + " svelte-wfkbxe"));
    			add_location(main, file, 111, 0, 4841);
    		},
    		l: function claim(nodes) {
    			throw new Error("options.hydrate only works if the component was compiled with the `hydratable: true` option");
    		},
    		m: function mount(target, anchor) {
    			insert_dev(target, main, anchor);
    			append_dev(main, main_wrap);
    			append_dev(main_wrap, item0);
    			append_dev(item0, t0);
    			append_dev(main_wrap, t1);
    			append_dev(main_wrap, item1);
    			append_dev(main_wrap, t2);
    			append_dev(main_wrap, main_items);

    			for (let i = 0; i < each_blocks.length; i += 1) {
    				each_blocks[i].m(main_items, null);
    			}
    		},
    		p: function update(ctx, [dirty]) {
    			if (dirty & /*title*/ 2) set_data_dev(t0, /*title*/ ctx[1]);

    			if (dirty & /*onItemClick, _items, onSliderWheel*/ 28) {
    				each_value = /*_items*/ ctx[2];
    				validate_each_argument(each_value);
    				let i;

    				for (i = 0; i < each_value.length; i += 1) {
    					const child_ctx = get_each_context(ctx, each_value, i);

    					if (each_blocks[i]) {
    						each_blocks[i].p(child_ctx, dirty);
    					} else {
    						each_blocks[i] = create_each_block(child_ctx);
    						each_blocks[i].c();
    						each_blocks[i].m(main_items, null);
    					}
    				}

    				for (; i < each_blocks.length; i += 1) {
    					each_blocks[i].d(1);
    				}

    				each_blocks.length = each_value.length;
    			}

    			if (dirty & /*float*/ 1 && main_class_value !== (main_class_value = "" + (null_to_empty(/*float*/ ctx[0].split("|").map(func).join(" ")) + " svelte-wfkbxe"))) {
    				attr_dev(main, "class", main_class_value);
    			}
    		},
    		i: noop,
    		o: noop,
    		d: function destroy(detaching) {
    			if (detaching) detach_dev(main);
    			destroy_each(each_blocks, detaching);
    		}
    	};

    	dispatch_dev("SvelteRegisterBlock", {
    		block,
    		id: create_fragment.name,
    		type: "component",
    		source: "",
    		ctx
    	});

    	return block;
    }

    const func = e => "float-" + e;

    function instance($$self, $$props, $$invalidate) {
    	let { float = "left|top" } = $$props;
    	let { title = "Untitled ESX Menu" } = $$props;

    	let { items = [
    		{
    			name: "foo",
    			label: "slider test",
    			type: "slider",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		},
    		{
    			name: "foo",
    			label: "bar",
    			type: "default",
    			visible: !0
    		}
    	] } = $$props;

    	let { _items = [] } = $$props;

    	window.addEventListener("message", e => {
    		const msg = e.data;

    		switch (msg.action) {
    			case "set":
    				{
    					$$invalidate(0, float = msg.data.float || "left|top");
    					$$invalidate(1, title = msg.data.title || "Untitled ESX Menu");
    					$$invalidate(5, items = msg.data.items || []);
    					break;
    				}
    			case "set_item":
    				{
    					$$invalidate(5, items[msg.index][msg.prop] = msg.val, items);
    					$$invalidate(5, items = [...items]);
    					break;
    				}
    		}
    	});

    	const proxifyItems = () => {
    		$$invalidate(2, _items.length = 0, _items);

    		for (let i = 0; i < items.length; i++) {
    			(i => {
    				$$invalidate(
    					2,
    					_items[i] = new Proxy(items[i],
    					{
    							get: (obj, prop) => {
    								return obj[prop];
    							},
    							set: (obj, prop, val) => {
    								obj[prop] = val;

    								window.parent.postMessage(
    									{
    										action: "item.change",
    										index: i,
    										prop,
    										val
    									},
    									"*"
    								);

    								return true;
    							},
    							has: (obj, prop) => {
    								return obj[prop] !== undefined;
    							},
    							ownKeys: obj => {
    								return Object.keys(obj);
    							}
    						}),
    					_items
    				);
    			})(i);
    		}

    		$$invalidate(2, _items = [..._items]);
    	};

    	onMount(() => {
    		window.parent.postMessage({ action: "ready" }, "*");
    	});

    	beforeUpdate(proxifyItems);

    	const onItemClick = (e, item, index) => {
    		window.parent.postMessage({ action: "item.click", index }, "*");
    	};

    	const onSliderWheel = (e, item, index) => {
    		if (e.deltaY > 0 && item.value > item.min) item.value--; else if (e.deltaY < 0 && item.value < item.max) item.value++;
    	};

    	const writable_props = ["float", "title", "items", "_items"];

    	Object_1.keys($$props).forEach(key => {
    		if (!~writable_props.indexOf(key) && key.slice(0, 2) !== "$$") console.warn(`<App> was created with unknown prop '${key}'`);
    	});

    	let { $$slots = {}, $$scope } = $$props;
    	validate_slots("App", $$slots, []);
    	const click_handler = (item, i, e) => onItemClick(e, item, i);

    	function input_change_input_handler(item) {
    		item.value = to_number(this.value);
    		$$invalidate(2, _items);
    	}

    	const click_handler_1 = (item, i, e) => onItemClick(e, item, i);
    	const wheel_handler = (item, i, e) => onSliderWheel(e, item);

    	function input_change_handler(item) {
    		item.value = this.checked;
    		$$invalidate(2, _items);
    	}

    	const click_handler_2 = (item, i, e) => {
    		onItemClick(e, item, i);
    		$$invalidate(2, item.value = !item.value, _items);
    	};

    	function input_input_handler(item) {
    		item.value = this.value;
    		$$invalidate(2, _items);
    	}

    	const click_handler_3 = (item, i, e) => onItemClick(e, item, i);

    	$$self.$set = $$props => {
    		if ("float" in $$props) $$invalidate(0, float = $$props.float);
    		if ("title" in $$props) $$invalidate(1, title = $$props.title);
    		if ("items" in $$props) $$invalidate(5, items = $$props.items);
    		if ("_items" in $$props) $$invalidate(2, _items = $$props._items);
    	};

    	$$self.$capture_state = () => ({
    		onMount,
    		beforeUpdate,
    		float,
    		title,
    		items,
    		_items,
    		proxifyItems,
    		onItemClick,
    		onSliderWheel
    	});

    	$$self.$inject_state = $$props => {
    		if ("float" in $$props) $$invalidate(0, float = $$props.float);
    		if ("title" in $$props) $$invalidate(1, title = $$props.title);
    		if ("items" in $$props) $$invalidate(5, items = $$props.items);
    		if ("_items" in $$props) $$invalidate(2, _items = $$props._items);
    	};

    	if ($$props && "$$inject" in $$props) {
    		$$self.$inject_state($$props.$$inject);
    	}

    	return [
    		float,
    		title,
    		_items,
    		onItemClick,
    		onSliderWheel,
    		items,
    		proxifyItems,
    		click_handler,
    		input_change_input_handler,
    		click_handler_1,
    		wheel_handler,
    		input_change_handler,
    		click_handler_2,
    		input_input_handler,
    		click_handler_3
    	];
    }

    class App extends SvelteComponentDev {
    	constructor(options) {
    		super(options);
    		init(this, options, instance, create_fragment, safe_not_equal, { float: 0, title: 1, items: 5, _items: 2 });

    		dispatch_dev("SvelteRegisterComponent", {
    			component: this,
    			tagName: "App",
    			options,
    			id: create_fragment.name
    		});
    	}

    	get float() {
    		throw new Error("<App>: Props cannot be read directly from the component instance unless compiling with 'accessors: true' or '<svelte:options accessors/>'");
    	}

    	set float(value) {
    		throw new Error("<App>: Props cannot be set directly on the component instance unless compiling with 'accessors: true' or '<svelte:options accessors/>'");
    	}

    	get title() {
    		throw new Error("<App>: Props cannot be read directly from the component instance unless compiling with 'accessors: true' or '<svelte:options accessors/>'");
    	}

    	set title(value) {
    		throw new Error("<App>: Props cannot be set directly on the component instance unless compiling with 'accessors: true' or '<svelte:options accessors/>'");
    	}

    	get items() {
    		throw new Error("<App>: Props cannot be read directly from the component instance unless compiling with 'accessors: true' or '<svelte:options accessors/>'");
    	}

    	set items(value) {
    		throw new Error("<App>: Props cannot be set directly on the component instance unless compiling with 'accessors: true' or '<svelte:options accessors/>'");
    	}

    	get _items() {
    		throw new Error("<App>: Props cannot be read directly from the component instance unless compiling with 'accessors: true' or '<svelte:options accessors/>'");
    	}

    	set _items(value) {
    		throw new Error("<App>: Props cannot be set directly on the component instance unless compiling with 'accessors: true' or '<svelte:options accessors/>'");
    	}
    }

    // Copyright (c) Jérémie N'gadi

    const app = new App({
    	target: document.body,
    	props: {}
    });

    return app;

}());
//# sourceMappingURL=bundle.js.map
