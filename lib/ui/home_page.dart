import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_to_do_app/controllers/task_controller.dart';
import 'package:flutter_to_do_app/models/task.dart';
import 'package:flutter_to_do_app/services/notification_services.dart';
import 'package:flutter_to_do_app/services/theme_services.dart';
import 'package:flutter_to_do_app/ui/add_task_page.dart';
import 'package:flutter_to_do_app/ui/theme.dart';
import 'package:flutter_to_do_app/ui/widgets/button.dart';
import 'package:flutter_to_do_app/ui/widgets/task_tile.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final TaskController _taskController = Get.put(TaskController());
  var notifyHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    _taskController.getTasks();
    print("home page init state");
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('tr');
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: context.theme.backgroundColor,
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          _showTasks(),
        ],
      ),
    );
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
            itemCount: _taskController.taskList.length,
            itemBuilder: (_, index) {
              Task task = _taskController.taskList[index];
              // print(_taskController.taskList[index].toJson());
              if (task.repeat == 'Günlük') {
                var myTime = task.startTime.toString();
                notifyHelper.scheduledNotification(
                    int.parse(myTime.toString().split(":")[0]),
                    int.parse(myTime.toString().split(":")[1]),
                    task);
                return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                    child: FadeInAnimation(
                        child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showBottomSheet(
                                context, _taskController.taskList[index]);
                          },
                          child: TaskTile(_taskController.taskList[index]),
                        )
                      ],
                    )),
                  ),
                );
              }
              if (task.date == DateFormat.yMd('tr').format(_selectedDate)) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                    child: FadeInAnimation(
                        child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showBottomSheet(
                                context, _taskController.taskList[index]);
                          },
                          child: TaskTile(_taskController.taskList[index]),
                        )
                      ],
                    )),
                  ),
                );
              } else {
                return Container();
              }
            });
      }),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height: task.isCompleted == 1
            ? MediaQuery.of(context).size.height * 0.24
            : MediaQuery.of(context).size.height * 0.32,
        color: Get.isDarkMode ? darkGreyClr : white,
        child: Column(
          children: [
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
              ),
            ),
            Spacer(),
            task.isCompleted == 1
                ? Container()
                : _bottomSheetButton(
                    label: "Görev Tamamlandı",
                    onTap: () {
                      _taskController.markTaskCompleted(task.id!);
                      Get.back();
                    },
                    clr: primaryClr,
                    context: context,
                  ),
            _bottomSheetButton(
              label: "Görevi Sil",
              onTap: () {
                _taskController.delete(task);
                Get.back();
              },
              clr: Colors.red[400]!,
              context: context,
            ),
            SizedBox(
              height: 20,
            ),
            _bottomSheetButton(
              label: "İptal",
              onTap: () {
                Get.back();
              },
              clr: Colors.red[400]!,
              isClose: true,
              context: context,
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  _bottomSheetButton(
      {required String label,
      required Function()? onTap,
      required Color clr,
      bool isClose = false,
      required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose == true
                ? Get.isDarkMode
                    ? Colors.grey[600]!
                    : Colors.grey[300]!
                : clr,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose == true ? Colors.transparent : clr,
        ),
        child: Center(
            child: Text(
          label,
          style: isClose
              ? titleStyle
              : titleStyle.copyWith(
                  color: Colors.white,
                ),
        )),
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
        left: 20,
      ),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        locale: 'tr',
        dateTextStyle: GoogleFonts.openSans(
          textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        dayTextStyle: GoogleFonts.openSans(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        monthTextStyle: GoogleFonts.openSans(
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        onDateChange: (selectedDate) {
          setState(() {
            _selectedDate = selectedDate;
          });
        },
      ),
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMMd('tr').format(DateTime.now()),
                  style: subHeadingStyle,
                ),
                Text(
                  "Bugün",
                  style: HeadingStyle,
                ),
              ],
            ),
          ),
          MyButton(
              label: "+ Add Task",
              onTap: () async {
                await Get.to(AddTaskPage());
                print("yeni kayıt sonrası refrese data");
                _taskController.getTasks(); //refrese data
              }),
        ],
      ),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          ThemeService().switchTheme();
          NotifyHelper().displayNotification(
              title: "Tema Değişti",
              body: Get.isDarkMode ? "Gündüz Modu Aktif" : "Gece Modu Aktif");

          // NotifyHelper().scheduledNotification();
        },
        child: Icon(
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          size: 30,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundImage: Get.isDarkMode
              ? AssetImage("images/avatar2.png")
              : AssetImage("images/avatar.png"),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}

// Delete için kod
// _taskController.delete(_taskController.taskList[index]);
// Anında sayfanın yenilenmesi için
// _taskController.getTasks();




