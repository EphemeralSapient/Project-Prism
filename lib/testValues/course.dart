List<dynamic> fetchCourseData() {
  return [
    {
      'code': 'CS3451',
      'title': 'INTRODUCTION TO OPERATING SYSTEMS',
      'year': "2nd Year",
      'semester': "3rd",
      'department': "Engineering",
      'description':
          'Introduction to Operating Systems" is a course that covers the basics and functions of operating systems. Topics covered include an overview of computer systems and operating system structures, process management including process scheduling and synchronization, memory management including paging and virtual memory, storage management including disk scheduling and file systems, and an introduction to virtual machines and mobile operating systems like iOS and Android. The course aims to provide students with a solid understanding of operating system concepts and functionality through lectures, discussions, and practical examples. By the end of the course, students are expected to analyze various scheduling algorithms, understand deadlock prevention and avoidance, compare memory management schemes, explain file systems and I/O systems, and compare iOS and Android operating systems',
      'LTPC': [3, 0, 0, 3],
      'objectives': [
        'To understand the basics and functions of operating systems.',
        'To understand processes and threads',
        'To analyze scheduling algorithms and process synchronization.',
        'To understand the concept of deadlocks.',
        'To analyze various memory management schemes.',
        'To be familiar with I/O management and file systems.',
        'To be familiar with the basics of virtual machines and Mobile OS like iOS and Android.'
      ],
      'outcomes': [
        'CO1 : Analyze various scheduling algorithms and process synchronization.',
        'CO2 : Explain deadlock prevention and avoidance algorithms.',
        'CO3 : Compare and contrast various memory management schemes.',
        'CO4 : Explain the functionality of file systems, I/O systems, and Virtualization',
        'CO5 : Compare iOS and Android Operating Systems.'
      ],
      'prerequisites': '',
      'textbook': [
        'Abraham Silberschatz, Peter Baer Galvin and Greg Gagne, "Operating System Concepts", 10th Edition, John Wiley and Sons Inc., 2018.',
        'Andrew S Tanenbaum, "Modern Operating Systems", Pearson, 5th Edition, 2022 New Delhi.'
      ],
      'reference': [
        'Ramaz Elmasri, A. Gil Carrick, David Levine, "Operating Systems - A Spiral Approach", Tata McGraw Hill Edition, 2010.',
        'William Stallings, "Operating Systems: Internals and Design Principles", 7th Edition, Prentice Hall, 2018.',
        'Achyut S.Godbole, Atul Kahate, "Operating Systems", McGraw Hill Education, 2016.'
      ],
      'ppt_resource': '',
      'updates': '',
      'syllabus_topic': [
        'INTRODUCTION',
        'PROCESSES',
        'MEMORY MANAGEMENT',
        'STORAGE MANAGEMENT',
        'VIRTUAL MACHINES AND MOBILE OS'
      ],
      'syllabus_credits': [7, 11, 10, 10, 7],
      'syllabus_subtopic': [
        'Computer System - Elements and organization; Operating System Overview - Objectives and Functions - Evolution of Operating System; Operating System Structures – Operating System Services - User Operating System Interface - System Calls – System Programs - Design and Implementation - Structuring methods.',
        'Processes - Process Concept - Process Scheduling - Operations on Processes - Inter-process Communication; CPU Scheduling - Scheduling criteria - Scheduling algorithms: Threads - Multithread Models – Threading issues; Process Synchronization - The Critical-Section problem - Synchronization hardware – Semaphores – Mutex - Classical problems of synchronization - Monitors; Deadlock - Methods for handling deadlocks, Deadlock prevention, Deadlock avoidance, Deadlock detection, Recovery from deadlock.',
        'Main Memory - Swapping - Contiguous Memory Allocation – Paging - Structure of the Page Table - Segmentation, Segmentation with paging; Virtual Memory - Demand Paging – Copy on Write - Page Replacement - Allocation of Frames –Thrashing.',
        'Mass Storage system – Disk Structure - Disk Scheduling and Management; File-System Interface - File concept - Access methods - Directory Structure - Directory organization - File system mounting - File Sharing and Protection; File System Implementation - File System Structure - Directory implementation - Allocation Methods - Free Space Management; I/O Systems – I/O Hardware, Application I/O interface, Kernel I/O subsystem',
        'Virtual Machines – History, Benefits and Features, Building Blocks, Types of Virtual Machines and their Implementations, Virtualization and Operating-System Components; Mobile OS - iOS and Android.'
      ],
      'handlingFaculty': ["UID here"],
    },
  ];
}
