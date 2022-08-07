using System.Collections.Generic;
using UnityEngine;

public struct ListBuffer<T> where T : struct
{
    int count;
    public ComputeBuffer buffer;
    string bufferName;
    int binarySize;
    List<T> list;

    public bool isEmpty;

    public ListBuffer(string bufferName, int binarySize)
    {
        this.buffer = null;
        this.bufferName = bufferName;
        this.binarySize = binarySize;
        count = -1;
        list = new List<T>(100);
        isEmpty = true;
    }

    public void UpdateData(int kernelHandle, ComputeShader shader)
    {
        EnsureBuffer();
        shader.SetBuffer(kernelHandle, bufferName, buffer);
        buffer.SetData(list);
    }

    void EnsureBuffer()
    {
        if (list.Count == 0)
        {
            list.Add(default);
            isEmpty = true;
        }

        if (count != list.Count)
        {
            if (buffer != null)
                buffer.Dispose();
            count = list.Count;
            buffer = new ComputeBuffer(count, binarySize);
        }
    }

    public void EnsureSize(int kernelHandle, ComputeShader shader, int size)
    {
        if (count != size)
        {
            if (buffer != null)
                buffer.Dispose();

            count = size;
            buffer = new ComputeBuffer(count, binarySize);

            //nasty test
            list.Clear();
            //for (int i = 0; i < size; i++)
            //{
            //    list.Add(new T());
            //}
            //buffer.SetData(list);
        }
        shader.SetBuffer(kernelHandle, bufferName, buffer);
    }

    public void Add(T element)
    {
        list.Add(element);
        isEmpty = false;
    }

    public void AddRange(List<T> elements)
    {
        for (int i = 0; i < elements.Count; i++)
        {
            list.Add(elements[i]);
        }
        isEmpty = false;
    }
    public void AddRange(T[] elements)
    {
        for (int i = 0; i < elements.Length; i++)
        {
            list.Add(elements[i]);
        }
        isEmpty = false;
    }


    public void Clear()
    {
        list.Clear();
        isEmpty = true;
    }

    public List<T> GetList()
    {
        return list;
    }

    public void Dispose()
    {
        isEmpty = true;
        if (buffer != null)
            buffer.Dispose();
    }
}