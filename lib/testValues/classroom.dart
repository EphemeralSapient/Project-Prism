import 'package:cloud_firestore/cloud_firestore.dart';

var classroomData = {
  'class': 'CSE', // Name of the class/program
  'year': 'II', // Year of study
  'students': ['uid1', 'uid2'], // List of student IDs in the class
  'section': 'A', // Section of the class
  'courses': ['CS1234'], // List of course codes associated with the class
  'class_count': 65, // Total number of students in the class
  'blacklist': ['uid1'], // List of student IDs blacklisted from the class
  'timetable': {
    'Monday': ['CS1234']
  }, // Timetable with class schedule for each day
  'department': 'Engineering', // Department or discipline of the class
  'delegate': {
    'uid1': 'Class representative'
  }, // Dictionary mapping student ID to class representative role
  'timetable_timing': 'timing_id', // ID or code for the class timetable timing
  'tutors': ['uid1'], // List of tutor IDs associated with the class
  'advisor': 'uid1', // ID of the advisor for the class
  'attendance': {
    'check': Timestamp
        .now(), // Timestamp object representing the timestamp of attendance check
    'absent': ['uid1'], // List of student IDs marked as absent
    'on_duty': [
      'uid1'
    ], // List of student IDs marked as on-duty or excused from attendance
  }
};
