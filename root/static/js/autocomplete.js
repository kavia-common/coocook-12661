const DEFAULT_ENDPOINT = {
    url: window.location,
    searchKey: "search",
    limitKey: "limit",
    limit: 0,
    additionalQuery: ""
};

const DEFAULT_PREFIX = {
    default: ""
};

class Autocomplete extends HTMLElement {
    constructor() {
        super();

        this.alertFunc = window[this.getAttribute("msg-func")];
        this.invalid = JSON.parse(this.getAttribute("invalid"));
        this.minLength = parseInt(this.getAttribute("min-length")) || 2;
        this.renderFunc = window[this.getAttribute("render")];
        if (typeof this.renderFunc !== "function") this.renderFunc = data => [JSON.stringify(data), JSON.stringify(data)];
        this.filterFunc = window[this.getAttribute("filter")];
        if (typeof this.filterFunc !== "function") this.filterFunc = data => data;
        this.currentFocus = -1;
        const self = this;
        this.setupEndpoint();

        // Create a shadow root
        const shadow = this.attachShadow({mode: "open"});
        
        const addInput = () => {
            const input = document.createElement("input");
            input.required = true;
            input.name = this.getAttribute("input-name") || null;
            input.type = "hidden";
            this.input = input;
    
            this.parentNode.insertBefore(input, this.nextSibling)
            this.closest("form").addEventListener("submit", e => {
                if (!input.value) {
                    e.preventDefault();
                    
                    if (this.alertFunc && this.invalid) {
                        this.alertFunc(...this.invalid);
                    }
                }
            })
        }

        const createContent = () => {
            const input = document.createElement("input");
            self.search = input;
            input.className = "form-control";
            input.type = "search";
            shadow.append(input);
    
            const container = document.createElement("div");
            container.className = "autocomplete";
            shadow.append(container);
    
            const options = document.createElement("div");
            self.options = options;
            options.className = "items hide";
            container.append(options);
            self.setPosition();
    
            const value = document.createElement("div");
            value.className = "value";
            shadow.append(value);
    
            self.dValue = document.createElement("div");
            value.append(self.dValue);
    
            const clear = document.createElement("button");
            clear.className = "close";
            clear.addEventListener("click", () => self.setInput());
            value.append(clear);
        };

        const createLoader = () => {
            self.loader = document.createElement("div");
            self.loader.className = "load-wrapper";

            const circle = document.createElement("div");
            circle.className = "loader";
            self.loader.append(circle);
        };

        // Add input to form
        addInput();

        // Create loader
        createLoader();
        
        // Apply styles to the shadow DOM
        const linkElem = document.createElement("link");
        linkElem.setAttribute("rel", "stylesheet");
        linkElem.setAttribute("href", "/static/css/autocomplete.css");
        shadow.append(linkElem);

        createContent();

        // Add event listener
        const label = document.querySelector(`[for=${this.id}]`);
        if (label) label.addEventListener("click", e => {
            e.preventDefault();
            this.search.focus();
        })

        this.search.addEventListener("keydown", e => {
            let list = this.options.children;
            if (e.key === "ArrowDown") {
                this.currentFocus++;
                this.addActive(list);
            } else if (e.key === "ArrowUp") {
                this.currentFocus--;
                this.addActive(list);
            } else if (e.key === "Enter") {
                e.preventDefault();
                if (this.currentFocus > -1) {
                    if (list) list[this.currentFocus].click();
                }
            }
        });

        this.search.addEventListener("input", e => {
            let val = e.target.value;
            this.options.innerHTML = "";
            if (!val || val.length <= this.minLength) {
                return;
            }
            this.currentFocus = -1;
            let ep = this.endpoint;
            this.options.append(this.loader)
            this.options.classList.remove("hide");
            this.setPosition();
            
            fetch(`${ep.url}?${ep.searchKey}=${val}${ep.limitKey && ep.limit ? `&${ep.limitKey}=${ep.limit}` : ""}${ep.additionalQuery ? `&${ep.additionalQuery}` : ""}`)
                .then(res => res.json())
                .then(data => {
                    this.loader.remove();
                    data = this.filterFunc(data);
                    for (let obj of data) {
                        this.createOption(obj, val);
                    }
                });
        });
    
        let ticking = false;

        document.addEventListener("scroll", (e) => {
            if (!ticking) {
                window.requestAnimationFrame(() => {
                    this.setPosition();
                    ticking = false;
                });
            
                ticking = true;
            }
        });

        document.addEventListener("click", e => {
            if (e.target !== this) {
                this.options.classList.add("hide");
                this.search.value = "";
            }
        });
    }

    setupEndpoint() {
        let tmp = JSON.parse(this.getAttribute("endpoint"));
        if (tmp === null || Array.isArray(tmp) || typeof tmp !== "object") tmp = {};

        this.endpoint = {...DEFAULT_ENDPOINT};
        Object.assign(this.endpoint, tmp);
    }

    setInput(value="", display="") {
        this.search.value = "";
        this.input.value = value;
        this.dValue.innerText = display;
    }

    removeActive(list) {
        for (let elem of list) {
            elem.classList.remove("active");
        }
    }

    addActive(list) {
        if (!list) return false;
        this.removeActive(list);
        if (this.currentFocus >= list.length) this.currentFocus = 0;
        if (this.currentFocus < 0) this.currentFocus = (list.length - 1);
        list[this.currentFocus].classList.add("active");
        scroll(list[this.currentFocus]);

        function scroll(elem) {
            const container = elem.parentElement;
            const cBox = container.getBoundingClientRect();
            const eBox = elem.getBoundingClientRect();
            
            if (cBox.bottom < eBox.bottom) {
                container.scrollBy(0, Math.floor(eBox.bottom - cBox.bottom));
            }

            if (eBox.top < cBox.top) {
                container.scrollBy(0, Math.floor(eBox.top - cBox.top));
            }
        }
    }

    createOption(data, value) {
        const elem = document.createElement("div");
        elem.className = "option";
        
        const [display, val] = this.renderFunc(data);
        elem.innerHTML = `<span>${markSearch(display, value)}</span><input type="hidden" value="${val}">`;
        elem.addEventListener("click", () => {
            this.setInput(val, display);
            this.options.classList.add("hide");
        });
        this.options.append(elem);

        function markSearch(str, search) {
            const re = new RegExp(search.trim(), "gi");

            for (let match of re.exec(str)) {
                str = str.replace(match, `<b>${match}</b>`);
            }

            return str
        }
    }

    setPosition() {
        const iBox = this.search.getBoundingClientRect();
        const height = document.documentElement.clientHeight;
        const lowerSpace = height - Math.floor(iBox.bottom) - 1;
        const upperSpace = Math.floor(iBox.top);
        const boxHeight = Math.floor(height * 40 / 100) + 1;

        let action = "remove";
        if (lowerSpace < boxHeight) {
            action = "add";
            if (upperSpace < boxHeight) {
                action = "remove";
            }
        }
        
        this.options.classList[action]("top");
    }
}

customElements.define("cc-autocomplete", Autocomplete);