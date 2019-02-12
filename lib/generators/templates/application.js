// This will load all components from webface.js.
// If you don't want to load all components provided by Webface, simply
// copy the contents of path/to/webface/lib/webface.js file in place of the import directive and remove
// the components you don't want. However, don't forget to change the import paths because they're relative.
import { Webface } from "./path_to_webface.js";

// Import your own components like this:
// import MyComponent from "./components/my_component.js";

Webface.init();
