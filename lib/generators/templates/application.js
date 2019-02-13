// Loading Webface components one by one. We could load webface.js instead (in that case, we wouldn't need to define Webface variable below
// but we wanted to give more flexibility here. Remove components you don't actually intend to use. Less to load!
import { Logmaster                   } from './path_to_webface/logmaster.js'
import { Animator                    } from './path_to_webface/animator.js'
import { AjaxRequest                 } from './path_to_webface/ajax_request.js'
import { Component                   } from './path_to_webface/component.js'
import { RootComponent               } from './path_to_webface/components/root_component.js'
import { ButtonComponent             } from './path_to_webface/components/button_component.js'
import { CheckboxComponent           } from './path_to_webface/components/checkbox_component.js'
import { FormFieldComponent          } from './path_to_webface/components/form_field_component.js'
import { NumericFormFieldComponent   } from './path_to_webface/components/numeric_form_field_component.js'
import { ModalWindowComponent        } from './path_to_webface/components/modal_window_component.js'
import { DialogWindowComponent       } from './path_to_webface/components/dialog_window_component.js'
import { RadioButtonComponent        } from './path_to_webface/components/radio_button_component.js'
import { HintComponent               } from './path_to_webface/components/hint_component.js'
import { SimpleNotificationComponent } from './path_to_webface/components/simple_notification_component.js'
import { SelectComponent             } from './path_to_webface/components/select_component.js'
import { ConfirmableButtonComponent  } from './path_to_webface/components/confirmable_button_component.js'
import { ContextMenuComponent        } from './path_to_webface/components/context_menu_component.js'

// Import your own components like this:
// import { MyComponent } from "./components/my_component.js";

window.webface.substitute_classes = { "Animator": Animator }

// Change these settings to your liking
AjaxRequest.display_40x  = true;
AjaxRequest.log_request  = true;
AjaxRequest.log_response = true;
AjaxRequest.user_notification = (message) => {
  // Put code that informs user of a bad ajax-request here
  // By default if does nothing.
};

export var Webface = {

  "init": (root_el=document.querySelector("body")) => {

    window.webface["logger"] = new Logmaster({test_env: false, reporters: { "console" : "DEBUG", "http" : "ERROR" }, throw_errors: true, http_report_url: "/report_webface_error"})

    try {
      var root = new RootComponent();
      root.dom_element = root_el;
      root.initChildComponents();
    } catch(e) {
      window.webface.logger.capture(e, { log_level: "ERROR" });
    }

  },

}

Webface.init();
