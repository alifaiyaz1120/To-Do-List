import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // this is added
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // used for time and calender
import 'main.dart';

class TasksPage extends StatefulWidget {
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // used for firebase 
  final TextEditingController taskController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // added for the scroll feature 

  late Stream<List<Task>> tasksStream; // lists of tasks 
  String _userName = ''; // create string to add user logged in

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // made a function that fetches the username logged in 
    tasksStream = fetchTasksAsStream(); // updates the task itself 
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  // this function is used to fetch the username that is logged in
  Future<void> _fetchUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userUid = user.uid;
      // pulls the users 
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userUid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final username = userData['username'];
        
        if (username != null) {
          setState(() {
            _userName = username; // replaces the string value
          });
        }
      }
    }
  }
  Future<void> _showAddTaskDialog() async {
    DateTime setDate = DateTime.now();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(24.0),
          content: Container( // add task popup container
            width: 600,
            height: 500,
            child: Column(
              children: [
                Text(
                  'Add New Task',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Container( //title container
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TextField(
                          controller: taskController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter title',
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Container( //description container
                        padding: EdgeInsets.all(8.0),
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter description',
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Due Date',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded( //select date container
                            child: TextField(
                              readOnly: true,
                              controller: dateController,
                              decoration: InputDecoration(
                                hintText: "Select Date"
                              ),
                              onTap: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2050),
                                );
                                if (pickedDate != null && pickedDate != selectedDate) {
                                  setState(() {
                                    selectedDate = DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day,
                                      selectedDate.hour,
                                      selectedDate.minute,
                                    );
                                    dateController.text = DateFormat('MMMM d, yyyy').format(selectedDate);
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded( //select time container
                            child: TextField(
                              readOnly: true,
                              controller: timeController,
                              decoration: InputDecoration(
                                hintText: "Select Time"
                              ),
                              onTap: () async {
                                final TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(selectedDate),
                                );
                                if (pickedTime != null) {
                                  setState(() {
                                    selectedDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                    timeController.text = DateFormat('h:mm a').format(selectedDate);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton( //cancel button
                  onPressed: () {
                    Navigator.of(context).pop();
                    taskController.clear();
                    descriptionController.clear();
                    dateController.clear();
                    timeController.clear();
                    setState(() {
                      selectedDate = DateTime.now();
                    });
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton( //add task button
                  onPressed: () {
                    final String taskText = taskController.text;
                    final String descriptionText = descriptionController.text;
                    final String dateText = dateController.text;
                    final String timeText = timeController.text;

                    if (taskText.isEmpty || descriptionText.isEmpty || dateText.isEmpty || timeText.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Missing Required Input'),
                            content: Text('Please fill out all required fields'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      final user = _auth.currentUser; //add all inputs to firbease
                      if (user != null) {
                        final userUid = user.uid;
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(userUid)
                            .collection('tasks')
                            .add({
                          'task': taskText,
                          'description': descriptionText,
                          'date': dateText,
                          'time': timeText,
                          'isCompleted': false,
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                      }
                      Navigator.of(context).pop();
                      taskController.clear();
                      descriptionController.clear();
                      dateController.clear();
                      timeController.clear();
                      setState(() {
                        selectedDate = DateTime.now();
                      });
                    }
                  },
                  child: Text(
                    'Add Task',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return Scaffold( 
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.lightBlue.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'To-Do List',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned( // used to position the text on the page "Today's Task"
            top: 160,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Task List",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentDate,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0.95, -0.93),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // to display the username on top of the page 
                Text(
                  'Hello, $_userName',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    onPrimary: Colors.white,
                  ),
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned( // used to position the button on the page "Add New Task"
            top: 140,
            right: 16,
            child: Container(
              width: 160,
              height: 48,
              child: ElevatedButton(
                onPressed: _showAddTaskDialog,
                child: Text(
                  'Add New Task',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          // used to position the list of tasks on the page
         Center(
            child: Container(
              width: 800, // set the desired width of the box
              height: 500, // set the desired height of the box
              padding: EdgeInsets.all(20), // add padding as needed
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: StreamBuilder<List<Task>>(
                    stream: tasksStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No tasks found.');
                      } else {
                        final tasks = snapshot.data!;
                        return ListView(
                          controller: _scrollController,
                          children: tasks.map((task) {
                            return Column(
                              children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // White background
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.7), // Gray border with higher opacity
                                width: 2.0, // Increase border width
                              ),
                              borderRadius: BorderRadius.circular(10), // Add rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5), // Gray shadow with opacity
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                              child: Padding(
                                padding: EdgeInsets.all(35), // Add padding inside the TodoBox
                                child: TodoBox(task: task),
                              ),
                            ),
                                SizedBox(height: 40), // Add spacing between task boxes
                              ],
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<Task>> fetchTasksAsStream() {
    final user = _auth.currentUser;
    if (user != null) {
      final userUid = user.uid;
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('tasks')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Task(
            id: doc.id,
            task: data['task'] as String,
            description: data['description'] as String,
            date: data['date'] as String,
            time: data['time'] as String,
            isCompleted: data['isCompleted'] as bool? ?? false,
          );
        }).toList();
      });
    } else {
      // return an empty stream if the user is not authenticated
      return Stream.value([]);
    }
  }
}

class Task { // class for the task which is used to store the data 
  final String id;
  final String task;
  final String description;
  final String date;
  final String time;
  final bool isCompleted;

  Task({ // constructor for the task
    required this.id,
    required this.task,
    required this.description,
    required this.date,
    required this.time,
    required this.isCompleted,
  });

  String get getTask => task;
}

Future<List<Task>> fetchTasks() async { // function to fetch the tasks from firebase
  List<Task> tasks = [];
  final QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('tasks').get(); // gets the tasks from the collection

  for (final QueryDocumentSnapshot document in querySnapshot.docs) { // loops through the documents
    final data = document.data() as Map<String, dynamic>;
    final task = data['task'] as String;
    final description = data['description'] as String;
    final date = data['date'] as String;
    final time = data['time'] as String;
    final isCompleted = data['isCompleted'] as bool? ?? false;

    tasks.add(Task( // adds the task to the list
      id: document.id,
      task: task,
      description: description,
      date: date,
      time: time,
      isCompleted: isCompleted,
    ));
  }

  return tasks; // returns the list of tasks from firebase
}

class TodoBox extends StatefulWidget { 
  final Task task;

  TodoBox({required this.task});

  @override
  _TodoBoxState createState() => _TodoBoxState();
}

class _TodoBoxState extends State<TodoBox> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.task.isCompleted;
  }

   @override
Widget build(BuildContext context) {
  // Define a TextStyle with the desired font size
  TextStyle textStyle = TextStyle(fontSize: 18.0); // Adjust the font size as needed

  return ListTile(
    title: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Title: ${widget.task.getTask}',
            style: textStyle, // Apply the TextStyle to the text
          ),
          Text(
            'Description: ${widget.task.description}',
            style: textStyle, // Apply the TextStyle to the text
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.5),
                  width: 2.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Due Date: ${widget.task.date}',
                  style: textStyle, // Apply the TextStyle to the text
                ),
                SizedBox(width: 10),
                Text(
                  'Time: ${widget.task.time}',
                  style: textStyle, // Apply the TextStyle to the text
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    trailing: IconButton(
      icon: Icon(
        Icons.cancel,
        color: Colors.red,
      ),
      onPressed: () {
        deleteTask();
      },
    ),
  );
}


  // pop us used for confirming if u want to delete
  void deleteTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // calls the function to delete from the firebase storage when called
                deleteTask_storage();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

void deleteTask_storage() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userUid = user.uid;

      // delete the task from firestore by its ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('tasks')
          .doc(widget.task.id) // use the task's ID 
          .delete();

      // check if the widget is still mounted before calling setState
      // mounted needed to be used or says data leaked on terminal
      if (mounted) {
        setState(() {
        });
      }
    }
  } catch (e) {
    print('Error deleting task: $e');
  }
}
}
