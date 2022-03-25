// Can I avoid this hardcoded path?
import "../assets/node_modules/xterm/css/xterm.css"
import { Terminal } from "../assets/node_modules/xterm"

export default IExTerminal = {
    mounted() {
        let term = new Terminal();
        term.open(this.el.querySelector(".terminal_element"));
        term.onKey(key => {
            this.pushEvent("key", key);
        });

        this.handleEvent("print_" + this.el.id, e => {
            term.write(e.data);
        });
    }
}
