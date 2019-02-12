import { Logmaster } from './webface_source/logmaster.js'
import { TestAnimator  } from './test_animator.js' // required to make some unit tests dependent on animation pass

window.webface = {
  "component_classes" : {},
  "logger"            : new Logmaster({test_env: true}),
  "substitute_classes": { "Animator": TestAnimator }
};

window.webface.logmaster_print_spy = chai.spy.on(window.webface.logger, "_print");
