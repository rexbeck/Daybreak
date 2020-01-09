import UIKit
import CalendarKit
import DateToolsSwift

enum SelectedStyle {
  case Dark
  case Light
}

class ExampleController: DayViewController, DatePickerControllerDelegate {

    
//MARK: List of Premade Events
  var data = [["Breakfast at Tiffany's",
               "New York, 5th avenue"],
              
              ["Eating Sandwiches with Jake",
                "New Mexico"]

              ]
    
//Event colors
  var colors = [UIColor.blue,
                UIColor.purple,
                UIColor.green,
                UIColor.red]

//Setting the default startup
    var currentStyle = SelectedStyle.Light

  override func viewDidLoad() {
    super.viewDidLoad()
//Title that goes across the top, might not fit very well depending on what I do
    title = ""
//This is the different options for the navigation bar. To have multiple ones you need to have them be in an array with ...ButtonItems instead of ...ButtonItem
    navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Dark",
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(ExampleController.changeStyle)),
                                                        UIBarButtonItem(title: "+",
                                                        style: .done,
                                                        target: self,
                                                        action: #selector(ExampleController.customEvent))]

    navigationItem.leftBarButtonItems = [UIBarButtonItem(title: "Change Date",
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(ExampleController.presentDatePicker))]
    navigationController?.navigationBar.isTranslucent = true
    dayView.autoScrollToFirstEvent = true
    reloadData()
  }

//changeStyle is how you flip between dark and light mode. It's the action: inside the UIBarButtonItem
  @objc func changeStyle() {
    var title: String!
    var style: CalendarStyle!

//This is how it switches between light and dark mode. If you click the nav item it flips it
    if currentStyle == .Dark {
      currentStyle = .Light
      title = "Dark"
      style = StyleGenerator.defaultStyle()
    } else {
      title = "Light"
      style = StyleGenerator.darkStyle()
      currentStyle = .Dark
    }
//This is just changing everything based on the what was changed above
    updateStyle(style)
    navigationItem.rightBarButtonItem!.title = title
    navigationController?.navigationBar.barTintColor = style.header.backgroundColor
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:style.header.swipeLabel.textColor]
    reloadData()
  }

//This is the function for changing the date in the navigation bar
  @objc func presentDatePicker() {
    let picker = DatePickerController()
    picker.date = dayView.state!.selectedDate
    picker.delegate = self
    let navC = UINavigationController(rootViewController: picker)
    navigationController?.present(navC, animated: true, completion: nil)
  }
//This might be the function for changing the date in the navigation controller
  func datePicker(controller: DatePickerController, didSelect date: Date?) {
    if let date = date {
      dayView.state?.move(to: date)
    }
    controller.dismiss(animated: true, completion: nil)
  }
    
//Custom function to make it so that you can create and event.
    @objc func customEvent(){
    
    
    
  }

  // MARK: EventDataSource
  override func eventsForDate(_ date: Date) -> [EventDescriptor] {
//I think this might be creating the date and time for events. The TimeChunk is just setting the exact time so it could possibly be getting the current time and TimeInterval is what gets the date and time for an event.
    var date = date.add(TimeChunk.dateComponents(hours: Int(arc4random_uniform(10) + 5)))
    var events = [Event]()

//I have no idea what the for i in 0...4 is actually for. There's no mention of the i later on. It's possibly that it's just for picking one of the 4 colors which would match the amount but idk if that works cause its 0, 1, 2, 3, 4 which is 5 total colors. So who knows 🤷‍♂️
    for i in 0...4 {
//Alright so this is definitely getting the date and times for events. Looks like TimePeriod is that lists the times
      let event = Event()
      let duration = Int(arc4random_uniform(160) + 60)
      let datePeriod = TimePeriod(beginning: date,
                                  chunk: TimeChunk.dateComponents(minutes: duration))

//This is getting all the actual information with anything to do with the time and date. This might just be doing it for the premade ones that show up randomly however but the outline should be pretty similar.
      event.startDate = datePeriod.beginning!
      event.endDate = datePeriod.end!

      var info = data[Int(arc4random_uniform(UInt32(data.count)))]

      let timezone = TimeZone.ReferenceType.default
      info.append(datePeriod.beginning!.format(with: "MM.dd.YYYY", timeZone: timezone))
      info.append("\(datePeriod.beginning!.format(with: "HH:mm", timeZone: timezone)) - \(datePeriod.end!.format(with: "HH:mm", timeZone: timezone))")
      event.text = info.reduce("", {$0 + $1 + "\n"})
      event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
      event.isAllDay = Int(arc4random_uniform(2)) % 2 == 0

      // Event styles are updated independently from CalendarStyle
      // hence the need to specify exact colors in case of Dark style
//Looks like this is deciding which color everything has to be depending on if it's light or dark mode
      if currentStyle == .Dark {
        event.textColor = textColorForEventInDarkTheme(baseColor: event.color)
        event.backgroundColor = event.color.withAlphaComponent(0.6)
      }
//So the above thing might actually be for creating a new event or atleast an outline for it. Otherwise I don't think it would have the events.append(event)
      events.append(event)
        
//Absolutely no clue what this does
      let nextOffset = Int(arc4random_uniform(250) + 40)
      date = date.add(TimeChunk.dateComponents(minutes: nextOffset))
      event.userInfo = String(i)
    }

    return events
  }

  private func textColorForEventInDarkTheme(baseColor: UIColor) -> UIColor {
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    return UIColor(hue: h, saturation: s * 0.3, brightness: b, alpha: a)
  }

  // MARK: DayViewDelegate

//I can use the lower code to edit/delete the different things
  override func dayViewDidSelectEventView(_ eventView: EventView) {
    guard let descriptor = eventView.descriptor as? Event else {
      return
    }
    print("Event has been selected: \(descriptor) \(String(describing: descriptor.userInfo))")
  }

  override func dayViewDidLongPressEventView(_ eventView: EventView) {
    guard let descriptor = eventView.descriptor as? Event else {
      return
    }
    print("Event has been longPressed: \(descriptor) \(String(describing: descriptor.userInfo))")
  }

  override func dayView(dayView: DayView, willMoveTo date: Date) {
    print("DayView = \(dayView) will move to: \(date)")
  }

  override func dayView(dayView: DayView, didMoveTo date: Date) {
    print("DayView = \(dayView) did move to: \(date)")
  }

  override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
    print("Did long press timeline at date \(date)")
  }
}

