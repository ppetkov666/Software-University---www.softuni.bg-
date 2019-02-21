using System.Collections.Generic;

namespace Many_to_Many_releations
{
    public class Student
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public int Age { get; set; }
        public List<StudentCourse> Courses { get; set; }

    }
}
