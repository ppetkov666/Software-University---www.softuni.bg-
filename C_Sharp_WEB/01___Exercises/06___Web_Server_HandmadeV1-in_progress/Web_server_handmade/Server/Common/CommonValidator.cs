﻿namespace Web_server_handmade.Server.Common
{
    using System;
    public static class CommonValidator
    {
        public static void ThrowIfNull(object obj, string name)
        {
            if (obj == null)
            {
                throw new ArgumentNullException(name);
            }
        }
        public static void ThrowIfNullOrEmpthy(string text, string name)
        {   
            if (string.IsNullOrEmpty(text))
            {
                throw new ArgumentException($"{name} cannot be null or empthy", name);
            }
        }
    }
}
