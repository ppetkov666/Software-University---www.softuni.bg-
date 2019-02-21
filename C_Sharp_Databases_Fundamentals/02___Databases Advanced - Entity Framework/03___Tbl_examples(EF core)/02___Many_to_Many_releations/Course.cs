using System.Collections.Generic;

namespace Many_to_Many_releations
{
    public class Course
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public List<StudentCourse> Students { get; set; }
    }
}
