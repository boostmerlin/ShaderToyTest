//四叉树的c#版本
using System.Collections.Generic;
using UnityEngine;

public class TreeObject
{
    public TreeObject(Rect rect, object data = null)
    {
        this.rect = rect;
        this.data = data;
    }
    public Rect rect;
    public object data;
}

public class QuadTree
{
    //当前结点如果元素超过则分裂成新的4个子结点
    private static int MAX_OBJECTS = 10;
    //最大深度
    private static int MAX_LEVELS = 4;

    private int level;
    private List<TreeObject> objects;
    private Rect bounds;
    //0=右上, 1=左上，2=左下，3=右下
    private QuadTree[] nodes;

    public QuadTree(Rect bounds, int level = 0)
    {
        this.level = level;
        this.bounds = bounds;
        nodes = new QuadTree[4];
        objects = new List<TreeObject>();
    }

    public void Clear()
    {
        objects.Clear();
        for (int i = 0; i < nodes.Length; i++)
        {
            if (nodes[i] != null)
            {
                nodes[i].Clear();
                nodes[i] = null;
            }
        }
    }

    private void split()
    {
        int subWidth = (int)(bounds.width / 2);
        int subHeight = (int)(bounds.height / 2);
        int x = (int)bounds.x;
        int y = (int)bounds.y;
        int nextLevel = level + 1;

        nodes[0] = new QuadTree(new Rect(x + subWidth, y, subWidth, subHeight), nextLevel);
        nodes[1] = new QuadTree(new Rect(x, y, subWidth, subHeight), nextLevel);
        nodes[2] = new QuadTree(new Rect(x, y + subHeight, subWidth, subHeight), nextLevel);
        nodes[3] = new QuadTree(new Rect(x + subWidth, y + subHeight, subWidth, subHeight), nextLevel);
    }

    /*
	 * Determine which node the object belongs to
	 * @param Object pRect		bounds of the area to be checked, with x, y, width, height
	 * @return Integer		index of the subnode (0-3), or -1 if pRect cannot completely fit within a subnode and is part of the parent node
	 */
    private int getIndex(Rect pRect)
    {
        int index = -1;
        float verticalMidpoint = this.bounds.x + (this.bounds.width / 2),
            horizontalMidpoint = this.bounds.y + (this.bounds.height / 2);

        //pRect can completely fit within the top quadrants
        bool topQuadrant = pRect.y > horizontalMidpoint,
            //pRect can completely fit within the bottom quadrants
            bottomQuadrant = (pRect.y + pRect.height) < horizontalMidpoint;
        //pRect can completely fit within the left quadrants
        if (pRect.x < verticalMidpoint && pRect.x + pRect.width < verticalMidpoint)
        {
            if (topQuadrant)
            {
                index = 1;
            }
            else if (bottomQuadrant)
            {
                index = 2;
            }

            //pRect can completely fit within the right quadrants	
        }
        else if (pRect.x > verticalMidpoint)
        {
            if (topQuadrant)
            {
                index = 0;
            }
            else if (bottomQuadrant)
            {
                index = 3;
            }
        }

        return index;
    }

    public void Insert(TreeObject obj)
    {
        int i = 0,
             index;

        //if we have subnodes ...
        if (this.nodes[0] != null)
        {
            index = this.getIndex(obj.rect);
            if (index != -1)
            {
                this.nodes[index].Insert(obj);
                return;
            }
        }

        this.objects.Add(obj);

        if (this.objects.Count > MAX_OBJECTS && this.level < MAX_LEVELS)
        {
            if (nodes[0] == null)
            {
                this.split();
            }

            //add all objects to there corresponding subnodes
            while (i < this.objects.Count)
            {
                TreeObject to = objects[i];
                index = this.getIndex(to.rect);

                if (index != -1)
                {
                    this.nodes[index].Insert(to);
                    objects.Remove(to);
                }
                else
                {
                    i = i + 1;
                }
            }
        }
    }

    public List<TreeObject> Retrieve(List<TreeObject> inputObjects, Rect pRect)
    {
        if (nodes[0] != null) {
            int index = getIndex(pRect);
            if (index != -1)
            {
                nodes[index].Retrieve(inputObjects, pRect);
            }
            else
            {

            }
            inputObjects.AddRange(objects);
        }

        return inputObjects;
    }
}
