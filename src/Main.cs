using System;
using System.Runtime.InteropServices;

namespace HelloStaticLinking
{
    class MainClass
    {
        [DllImport("__Internal")]
        internal static extern IntPtr hello ();

        public static void Main (string[] args)
        {
            try {
                string c_str = Marshal.PtrToStringAnsi (hello());
                Console.WriteLine(c_str);
            } catch (Exception e) {
                Console.Error.WriteLine("Exception: " + e);
            }
        }
    }
}
