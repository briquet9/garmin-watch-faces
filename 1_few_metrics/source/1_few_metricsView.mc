import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class _1_few_metricsView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var WIDTH= dc.getWidth();
        var HEIGHT = dc.getHeight();

        // Get and show the current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var timeLabel = View.findDrawableById("TimeLabel") as Text;
        timeLabel.setText(timeString);

        // Battery
        var batteryLabel = View.findDrawableById("BatteryLabel") as Text;
        batteryLabel.setText(getBatteryString());

        // Date
        var dateLabel = View.findDrawableById("DateLabel") as Text;
        dateLabel.setText(getDate());

        // Heart rate
        var heartRateLabel = View.findDrawableById("HeartRateLabel") as Text;
        heartRateLabel.setText(getHeartRateString());

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Draw Body Battery and Steps arcs
        var ARCLENGTH = 60;
        var ARCWIDTH = 10;
        dc.setPenWidth(ARCWIDTH);

        // Draw Body Battery Arc
        dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(WIDTH/2, HEIGHT/2, HEIGHT/2 - ARCWIDTH / 2, Graphics.ARC_CLOCKWISE, 180 + ARCLENGTH / 2, 180 -ARCLENGTH / 2);

        if(getBodyBattery() != null) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(WIDTH/2, HEIGHT/2, HEIGHT/2 - ARCWIDTH / 2, Graphics.ARC_CLOCKWISE,  180 + ARCLENGTH / 2 , 180 +ARCLENGTH / 2 - ARCLENGTH * getBodyBattery()/100);
        }

        // Draw Steps Arc
        dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(WIDTH/2, HEIGHT/2, HEIGHT/2 - ARCWIDTH / 2, Graphics.ARC_COUNTER_CLOCKWISE, 0 - ARCLENGTH / 2, 0 + ARCLENGTH / 2);

        if(getSteps() > 0 && getStepGoal() != null) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(WIDTH/2, HEIGHT/2, HEIGHT/2 - ARCWIDTH / 2, Graphics.ARC_COUNTER_CLOCKWISE, 0 - ARCLENGTH / 2 , 0 - ARCLENGTH / 2 + ARCLENGTH * getStepsRatioThresholded());
        }

        // displayDebugLines(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    private function getDate() as String {
       var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
       var dateString = Lang.format("$1$ $2$ $3$",         [
                today.day_of_week,
                today.day,
                today.month,
            ]
        );
        return dateString;
    }

    private function getHeartRate() as Number  {
        var heartrateIterator = Toybox.ActivityMonitor.getHeartRateHistory(1, true);
	    return heartrateIterator.next().heartRate;
    }

    private function getHeartRateString() as String  {
	    return getHeartRate().format("%d");
    }

    private function getBodyBatteryIterator() {
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
            return Toybox.SensorHistory.getBodyBatteryHistory({:period=>1, :order=> Toybox.SensorHistory.ORDER_NEWEST_FIRST});
        }
        return null;
    }

    private function getBodyBattery() as Lang.Number or Null {
        var bbIterator = getBodyBatteryIterator();
        var sample = bbIterator.next();

        while (sample != null) {
            if(sample.data != null) {
                return sample.data;
            }
            sample = bbIterator.next();
        }

        return null;
    }

    private function getBodyBatteryString() as String {
        var bodyBattery = getBodyBattery();
        if (bodyBattery == null) {
            return "-";
        }
        return bodyBattery.format("%d") + "%";
    }

    private function getSteps() as Lang.Number or Null {
        return Toybox.ActivityMonitor.getInfo().steps;
    }

    private function getStepsString() as String {
        var steps = getSteps();
        if(steps == null) {
            return "-";
        }
        return getSteps().format("%d");
    }

    private function getStepGoal() as Lang.Number or Null {
        return Toybox.ActivityMonitor.getInfo().stepGoal;
    }

    private function getStepsRatioThresholded() as Lang.Float or Null {
        var stepGoal = getStepGoal();
        var steps = getSteps();

        if(steps ==null || stepGoal == null) {
            return null;
        }

        if(steps > stepGoal) {
            steps = stepGoal;
        }

        return 1.0 * steps / stepGoal;
    }

    private function getBattery() as Float  {
    	return Toybox.System.getSystemStats().battery;		
    }

    private function getBatteryString() as String  {
        return getBattery().format("%d")+"%"; 
    }

    private function displayDebugLines(dc as Dc) as Void {
        var WIDTH= dc.getWidth();
        var HEIGHT = dc.getHeight();

        dc.setPenWidth(1);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(0.2*WIDTH, 0.1*HEIGHT, 0.6*WIDTH,  0.8*HEIGHT );
        dc.drawRectangle(0.15*WIDTH, 0.15*HEIGHT, 0.7*WIDTH,  0.7*HEIGHT );
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(0.1*WIDTH, 0.2*HEIGHT, 0.8*WIDTH,  0.6*HEIGHT );
        dc.drawRectangle(0.05*WIDTH, 0.3*HEIGHT, 0.9*WIDTH,  0.4*HEIGHT );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0.25*HEIGHT, WIDTH,  1 );
        dc.fillRectangle(0, 0.5*HEIGHT, WIDTH,  1 );
        dc.fillRectangle(0, 0.75*HEIGHT, WIDTH,  1);
        dc.fillRectangle(0.25*WIDTH, 0 , 1, HEIGHT );

        dc.fillRectangle(0.1*WIDTH, 0, 1,  HEIGHT );
        dc.fillRectangle(0.9*WIDTH, 0, 1,  HEIGHT );

        dc.fillRectangle(0.5*WIDTH, 0, 1,  HEIGHT );
        dc.fillRectangle(0.75*WIDTH,0, 1,  HEIGHT);

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0.3333*WIDTH, 0 , 1, HEIGHT );
        dc.fillRectangle(0.6666*WIDTH, 0 , 1, HEIGHT );
    }
}
