import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class _0_hello_worldApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new _0_hello_worldView() ];
    }

}

function getApp() as _0_hello_worldApp {
    return Application.getApp() as _0_hello_worldApp;
}