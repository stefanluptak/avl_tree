defmodule AVLTreeTest do
  use ExUnit.Case
  alias AVLTree.Node

  doctest AVLTree, except: [view: 1]

  test "protocols" do
    tree1 = Enum.into([5, 9, 3, 8, 1, 6, 7], AVLTree.new())
    assert Enum.to_list(tree1) == [1, 3, 5, 6, 7, 8, 9]
    assert Enum.member?(tree1, 6)
    assert !Enum.member?(tree1, 10)
    tree2 = Enum.into([8, 4, 2, 5, 7, 2, 1, 3], AVLTree.new())
    assert Enum.to_list(tree2) == [1, 2, 2, 3, 4, 5, 7, 8]
    assert Enum.zip(tree1, tree2) == [{1, 1}, {3, 2}, {5, 2}, {6, 3}, {7, 4}, {8, 5}, {9, 7}]
  end

  test "new" do
    asc = &Kernel.</2
    desc = &Kernel.>/2

    %AVLTree{root: nil, size: 0, less: ^asc} = AVLTree.new()
    %AVLTree{root: nil, size: 0, less: ^asc} = AVLTree.new(:asc)
    %AVLTree{root: nil, size: 0, less: ^desc} = AVLTree.new(:desc)
  end

  test "put" do
    tree = Enum.into([5, 9, 3, 8, 1, 6, 7], AVLTree.new())
    assert Enum.to_list(tree) == [1, 3, 5, 6, 7, 8, 9]
    assert AVLTree.member?(tree, 3)
    assert !AVLTree.member?(tree, 2)

    assert AVLTree.size(tree) == 7
    assert AVLTree.height(tree) == 4

    assert inspect(tree) == "#AVLTree<[1, 3, 5, 6, 7, 8, 9]>"

    #    5
    #  ┌─┴───┐
    #  3     8
    # ┌┴┐  ┌─┴┐
    # 1    6  9
    #     ┌┴┐
    #       7
    assert tree.root ==
             %Node{
               value: 5,
               height: 4,
               left: %Node{
                 value: 3,
                 height: 2,
                 left: %Node{value: 1, height: 1, left: nil, right: nil},
                 right: nil
               },
               right: %Node{
                 value: 8,
                 height: 3,
                 left: %Node{
                   value: 6,
                   height: 2,
                   left: nil,
                   right: %Node{value: 7, height: 1, left: nil, right: nil}
                 },
                 right: %Node{value: 9, height: 1, left: nil, right: nil}
               }
             }

    tree = Enum.into([11, 10, 12], tree)
    assert Enum.to_list(tree) == [1, 3, 5, 6, 7, 8, 9, 10, 11, 12]
    assert AVLTree.size(tree) == 10
    assert AVLTree.height(tree) == 4

    #        8
    #    ┌───┴─┐
    #    5    10
    #  ┌─┴─┐  ┌┴─┐
    #  3   6  9 11
    # ┌┴┐ ┌┴┐   ┌┴─┐
    # 1     7     12
    assert tree.root ==
             %Node{
               value: 8,
               height: 4,
               left: %Node{
                 value: 5,
                 height: 3,
                 left: %Node{
                   value: 3,
                   height: 2,
                   left: %Node{value: 1, height: 1, left: nil, right: nil},
                   right: nil
                 },
                 right: %Node{
                   value: 6,
                   height: 2,
                   left: nil,
                   right: %Node{value: 7, height: 1, left: nil, right: nil}
                 }
               },
               right: %Node{
                 value: 10,
                 height: 3,
                 left: %Node{value: 9, height: 1, left: nil, right: nil},
                 right: %Node{
                   value: 11,
                   height: 2,
                   left: nil,
                   right: %Node{value: 12, height: 1, left: nil, right: nil}
                 }
               }
             }

    tree = AVLTree.put(tree, 4)
    assert Enum.to_list(tree) == [1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    assert AVLTree.size(tree) == 11
    assert AVLTree.height(tree) == 4

    #        8
    #    ┌───┴─┐
    #    5    10
    #  ┌─┴─┐  ┌┴─┐
    #  3   6  9 11
    # ┌┴┐ ┌┴┐   ┌┴─┐
    # 1 4   7     12
    assert tree.root ==
             %Node{
               value: 8,
               height: 4,
               left: %Node{
                 value: 5,
                 height: 3,
                 left: %Node{
                   value: 3,
                   height: 2,
                   left: %Node{
                     value: 1,
                     height: 1,
                     left: nil,
                     right: nil
                   },
                   right: %Node{value: 4, height: 1, left: nil, right: nil}
                 },
                 right: %Node{
                   value: 6,
                   height: 2,
                   left: nil,
                   right: %Node{value: 7, height: 1, left: nil, right: nil}
                 }
               },
               right: %Node{
                 value: 10,
                 height: 3,
                 left: %Node{value: 9, height: 1, left: nil, right: nil},
                 right: %Node{
                   value: 11,
                   height: 2,
                   left: nil,
                   right: %Node{value: 12, height: 1, left: nil, right: nil}
                 }
               }
             }

    assert tree == AVLTree.put(tree, 7)
  end

  test "get" do
    tree =
      [{5, 50}, {1, 10}, {9, 90}, {1, 20}, {5, 40}, {7, 70}, {2, 20}]
      |> Enum.into(AVLTree.new(fn {k1, _}, {k2, _} -> k1 < k2 end))

    assert AVLTree.get(tree, {7, nil}) == {7, 70}
    assert AVLTree.get(tree, {9, nil}) == {9, 90}
    assert AVLTree.get(tree, {5, nil}) == {5, 50}
    assert AVLTree.get(tree, {1, nil}) == {1, 20}
    assert AVLTree.get(tree, {6, nil}) == nil
    assert AVLTree.get(tree, {6, nil}, :error) == :error
  end

  test "get first/last" do
    tree =
      [{5, 50}, {1, 10}, {9, 90}, {1, 20}, {5, 40}, {7, 70}, {2, 20}]
      |> Enum.into(AVLTree.new(fn {k1, _}, {k2, _} -> k1 < k2 end))

    assert AVLTree.get_first(tree) == {1, 10}
    assert AVLTree.get_last(tree) == {9, 90}

    tree = AVLTree.new()
    assert AVLTree.get_first(tree) == nil
    assert AVLTree.get_first(tree, :error) == :error

    assert AVLTree.get_last(tree) == nil
    assert AVLTree.get_last(tree, :error) == :error
  end

  test "get lower/upper" do
    tree =
      [{5, 50}, {1, 10}, {9, 90}, {1, 20}, {5, 40}, {7, 70}, {2, 20}]
      |> Enum.into(AVLTree.new(fn {k1, _}, {k2, _} -> k1 < k2 end))

    assert AVLTree.get_lower(tree, {1, nil}) == {1, 10}
    assert AVLTree.get_upper(tree, {1, nil}) == {1, 20}

    assert AVLTree.get_lower(tree, {5, nil}) == {5, 50}
    assert AVLTree.get_upper(tree, {5, nil}) == {5, 40}

    assert AVLTree.get_lower(tree, {6, nil}) == nil
    assert AVLTree.get_upper(tree, {6, nil}) == nil

    assert AVLTree.get_lower(tree, {6, nil}, :error) == :error
    assert AVLTree.get_upper(tree, {6, nil}, :error) == :error
  end

  test "put/delete lower/upper" do
    tree =
      [{1, 10}, {5, 50}, {9, 90}, {7, 70}, {2, 20}]
      |> Enum.into(AVLTree.new(fn {k1, _}, {k2, _} -> k1 < k2 end))

    assert Enum.to_list(tree) == [{1, 10}, {2, 20}, {5, 50}, {7, 70}, {9, 90}]
    assert AVLTree.size(tree) == 5
    assert AVLTree.height(tree) == 3

    #         {5, 50}
    #    ┌───────┴───────┐
    # {1, 10}         {9, 90}
    #   ┌┴───┐       ┌───┴┐
    #     {2, 20} {7, 70}
    assert tree.root ==
             %Node{
               value: {5, 50},
               height: 3,
               left: %Node{
                 value: {1, 10},
                 height: 2,
                 left: nil,
                 right: %Node{
                   value: {2, 20},
                   height: 1,
                   left: nil,
                   right: nil
                 }
               },
               right: %Node{
                 value: {9, 90},
                 height: 2,
                 left: %Node{
                   value: {7, 70},
                   height: 1,
                   left: nil,
                   right: nil
                 },
                 right: nil
               }
             }

    tree = AVLTree.put(tree, {7, 700})
    assert Enum.to_list(tree) == [{1, 10}, {2, 20}, {5, 50}, {7, 700}, {9, 90}]
    assert AVLTree.size(tree) == 5
    assert AVLTree.height(tree) == 3

    #         {5, 50}
    #    ┌───────┴────────┐
    # {1, 10}          {9, 90}
    #   ┌┴───┐        ┌───┴┐
    #     {2, 20} {7, 700}
    assert tree.root ==
             %Node{
               value: {5, 50},
               height: 3,
               left: %Node{
                 value: {1, 10},
                 height: 2,
                 left: nil,
                 right: %Node{
                   value: {2, 20},
                   height: 1,
                   left: nil,
                   right: nil
                 }
               },
               right: %Node{
                 value: {9, 90},
                 height: 2,
                 left: %Node{
                   value: {7, 700},
                   height: 1,
                   left: nil,
                   right: nil
                 },
                 right: nil
               }
             }

    assert AVLTree.put_lower(tree, {8, 80}) == AVLTree.put_upper(tree, {8, 80})
    assert AVLTree.put_lower(tree, {8, 80}) == AVLTree.put(tree, {8, 80})

    tree = AVLTree.put_lower(tree, {7, 71})
    tree = AVLTree.put_lower(tree, {7, 72})
    tree = AVLTree.put_lower(tree, {7, 73})

    assert Enum.to_list(tree) == [
             {1, 10},
             {2, 20},
             {5, 50},
             {7, 73},
             {7, 72},
             {7, 71},
             {7, 700},
             {9, 90}
           ]

    assert AVLTree.size(tree) == 8
    assert AVLTree.height(tree) == 4

    #         {5, 50}
    #    ┌───────┴───────────────┐
    # {1, 10}                {7, 700}
    #   ┌┴───┐           ┌───────┴───┐
    #     {2, 20}     {7, 72}     {9, 90}
    #                ┌───┴───┐
    #             {7, 73} {7, 71}
    assert tree.root ==
             %Node{
               value: {5, 50},
               height: 4,
               left: %Node{
                 value: {1, 10},
                 height: 2,
                 left: nil,
                 right: %Node{
                   value: {2, 20},
                   height: 1,
                   left: nil,
                   right: nil
                 }
               },
               right: %Node{
                 value: {7, 700},
                 height: 3,
                 left: %Node{
                   value: {7, 72},
                   height: 2,
                   left: %Node{
                     value: {7, 73},
                     height: 1,
                     left: nil,
                     right: nil
                   },
                   right: %Node{
                     value: {7, 71},
                     height: 1,
                     left: nil,
                     right: nil
                   }
                 },
                 right: %Node{
                   value: {9, 90},
                   height: 1,
                   left: nil,
                   right: nil
                 }
               }
             }

    tree = AVLTree.put_upper(tree, {7, 74})
    tree = AVLTree.put_upper(tree, {7, 75})
    tree = AVLTree.put_upper(tree, {7, 76})

    assert Enum.to_list(tree) == [
             {1, 10},
             {2, 20},
             {5, 50},
             {7, 73},
             {7, 72},
             {7, 71},
             {7, 700},
             {7, 74},
             {7, 75},
             {7, 76},
             {9, 90}
           ]

    #                        {7, 700}
    #            ┌───────────────┴───────┐
    #         {5, 50}                 {7, 75}
    #    ┌───────┴───────┐           ┌───┴───────┐
    # {1, 10}         {7, 72}     {7, 74}     {9, 90}
    #   ┌┴───┐       ┌───┴───┐               ┌───┴┐
    #     {2, 20} {7, 73} {7, 71}         {7, 76}
    assert tree.root ==
             %Node{
               value: {7, 700},
               height: 4,
               left: %Node{
                 value: {5, 50},
                 height: 3,
                 left: %Node{
                   value: {1, 10},
                   height: 2,
                   left: nil,
                   right: %Node{value: {2, 20}, height: 1, left: nil, right: nil}
                 },
                 right: %Node{
                   value: {7, 72},
                   height: 2,
                   left: %Node{value: {7, 73}, height: 1, left: nil, right: nil},
                   right: %Node{value: {7, 71}, height: 1, left: nil, right: nil}
                 }
               },
               right: %Node{
                 value: {7, 75},
                 height: 3,
                 left: %Node{value: {7, 74}, height: 1, left: nil, right: nil},
                 right: %Node{
                   value: {9, 90},
                   height: 2,
                   left: %Node{value: {7, 76}, height: 1, left: nil, right: nil},
                   right: nil
                 }
               }
             }

    tree = AVLTree.delete_upper(tree, {7, nil})

    #                        {7, 700}
    #            ┌───────────────┴───────┐
    #         {5, 50}                 {7, 75}
    #    ┌───────┴───────┐           ┌───┴───┐
    # {1, 10}         {7, 72}     {7, 74} {9, 90}
    #   ┌┴───┐       ┌───┴───┐
    #     {2, 20} {7, 73} {7, 71}
    assert tree.root ==
             %Node{
               value: {7, 700},
               height: 4,
               left: %Node{
                 value: {5, 50},
                 height: 3,
                 left: %Node{
                   value: {1, 10},
                   height: 2,
                   left: nil,
                   right: %Node{value: {2, 20}, height: 1, left: nil, right: nil}
                 },
                 right: %Node{
                   value: {7, 72},
                   height: 2,
                   left: %Node{value: {7, 73}, height: 1, left: nil, right: nil},
                   right: %Node{value: {7, 71}, height: 1, left: nil, right: nil}
                 }
               },
               right: %Node{
                 value: {7, 75},
                 height: 2,
                 left: %Node{value: {7, 74}, height: 1, left: nil, right: nil},
                 right: %Node{value: {9, 90}, height: 1, left: nil, right: nil}
               }
             }

    tree = AVLTree.delete_lower(tree, {7, nil})

    #                    {7, 700}
    #            ┌───────────┴───────┐
    #         {5, 50}             {7, 75}
    #    ┌───────┴───┐           ┌───┴───┐
    # {1, 10}     {7, 72}     {7, 74} {9, 90}
    #   ┌┴───┐      ┌┴───┐
    #     {2, 20}     {7, 71}
    assert tree.root ==
             %Node{
               value: {7, 700},
               height: 4,
               left: %Node{
                 value: {5, 50},
                 height: 3,
                 left: %Node{
                   value: {1, 10},
                   height: 2,
                   left: nil,
                   right: %Node{value: {2, 20}, height: 1, left: nil, right: nil}
                 },
                 right: %Node{
                   value: {7, 72},
                   height: 2,
                   left: nil,
                   right: %Node{value: {7, 71}, height: 1, left: nil, right: nil}
                 }
               },
               right: %Node{
                 value: {7, 75},
                 height: 2,
                 left: %Node{value: {7, 74}, height: 1, left: nil, right: nil},
                 right: %Node{value: {9, 90}, height: 1, left: nil, right: nil}
               }
             }

    tree = AVLTree.delete_lower(tree, {7, nil})

    #                {7, 700}
    #            ┌───────┴───────┐
    #         {5, 50}         {7, 75}
    #    ┌───────┴───┐       ┌───┴───┐
    # {1, 10}     {7, 71} {7, 74} {9, 90}
    #   ┌┴───┐
    #     {2, 20}
    assert tree.root ==
             %Node{
               value: {7, 700},
               height: 4,
               left: %Node{
                 value: {5, 50},
                 height: 3,
                 left: %Node{
                   value: {1, 10},
                   height: 2,
                   left: nil,
                   right: %Node{value: {2, 20}, height: 1, left: nil, right: nil}
                 },
                 right: %Node{value: {7, 71}, height: 1, left: nil, right: nil}
               },
               right: %Node{
                 value: {7, 75},
                 height: 2,
                 left: %Node{value: {7, 74}, height: 1, left: nil, right: nil},
                 right: %Node{value: {9, 90}, height: 1, left: nil, right: nil}
               }
             }

    tree = AVLTree.delete_lower(tree, {7, nil})

    #            {7, 700}
    #        ┌───────┴───────┐
    #     {2, 20}         {7, 75}
    #    ┌───┴───┐       ┌───┴───┐
    # {1, 10} {5, 50} {7, 74} {9, 90}
    assert tree.root ==
             %Node{
               value: {7, 700},
               height: 3,
               left: %Node{
                 value: {2, 20},
                 height: 2,
                 left: %Node{value: {1, 10}, height: 1, left: nil, right: nil},
                 right: %Node{value: {5, 50}, height: 1, left: nil, right: nil}
               },
               right: %Node{
                 value: {7, 75},
                 height: 2,
                 left: %Node{value: {7, 74}, height: 1, left: nil, right: nil},
                 right: %Node{value: {9, 90}, height: 1, left: nil, right: nil}
               }
             }

    tree = AVLTree.delete_upper(tree, {7, nil})

    #            {7, 700}
    #        ┌───────┴───┐
    #     {2, 20}     {7, 74}
    #    ┌───┴───┐      ┌┴───┐
    # {1, 10} {5, 50}     {9, 90}

    assert tree.root ==
             %Node{
               value: {7, 700},
               height: 3,
               left: %Node{
                 value: {2, 20},
                 height: 2,
                 left: %Node{value: {1, 10}, height: 1, left: nil, right: nil},
                 right: %Node{value: {5, 50}, height: 1, left: nil, right: nil}
               },
               right: %Node{
                 value: {7, 74},
                 height: 2,
                 left: nil,
                 right: %Node{value: {9, 90}, height: 1, left: nil, right: nil}
               }
             }

    assert ^tree = AVLTree.delete_upper(tree, {6, nil})
    assert ^tree = AVLTree.delete_lower(tree, {6, nil})
  end

  test "delete" do
    tree = Enum.into([5, 9, 3, 8, 1, 6, 7], AVLTree.new())
    assert match?(^tree, AVLTree.delete(tree, 4))
    tree = AVLTree.delete(tree, 3)

    assert Enum.to_list(tree) == [1, 5, 6, 7, 8, 9]
    assert AVLTree.size(tree) == 6
    assert AVLTree.height(tree) == 3

    #    6
    #  ┌─┴─┐
    #  5   8
    # ┌┴┐ ┌┴┐
    # 1   7 9
    assert tree.root ==
             %Node{
               value: 6,
               height: 3,
               left: %Node{
                 value: 5,
                 height: 2,
                 left: %Node{value: 1, height: 1, left: nil, right: nil},
                 right: nil
               },
               right: %Node{
                 value: 8,
                 height: 2,
                 left: %Node{value: 7, height: 1, left: nil, right: nil},
                 right: %Node{value: 9, height: 1, left: nil, right: nil}
               }
             }

    tree = AVLTree.delete(tree, 1)
    assert Enum.to_list(tree) == [5, 6, 7, 8, 9]
    assert AVLTree.size(tree) == 5 and AVLTree.height(tree) == 3

    #  6
    # ┌┴─┐
    # 5  8
    #   ┌┴┐
    #   7 9
    assert tree.root == %Node{
             value: 6,
             height: 3,
             left: %Node{value: 5, height: 1, left: nil, right: nil},
             right: %Node{
               value: 8,
               height: 2,
               left: %Node{value: 7, height: 1, left: nil, right: nil},
               right: %Node{value: 9, height: 1, left: nil, right: nil}
             }
           }

    tree = AVLTree.delete(tree, 8)
    assert Enum.to_list(tree) == [5, 6, 7, 9]
    assert AVLTree.size(tree) == 4 and AVLTree.height(tree) == 3

    #  6
    # ┌┴─┐
    # 5  7
    #   ┌┴┐
    #     9
    assert tree.root == %Node{
             value: 6,
             height: 3,
             left: %Node{value: 5, height: 1, left: nil, right: nil},
             right: %Node{
               value: 7,
               height: 2,
               left: nil,
               right: %Node{value: 9, height: 1, left: nil, right: nil}
             }
           }

    tree = Enum.into([3, 1, 2, 4, 8, 0], tree)
    assert Enum.to_list(tree) == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    assert AVLTree.size(tree) == 10 and AVLTree.height(tree) == 4

    #        6
    #    ┌───┴─┐
    #    3     8
    #  ┌─┴─┐  ┌┴┐
    #  1   5  7 9
    # ┌┴┐ ┌┴┐
    # 0 2 4
    assert tree.root ==
             %Node{
               value: 6,
               height: 4,
               left: %Node{
                 value: 3,
                 height: 3,
                 left: %Node{
                   value: 1,
                   height: 2,
                   left: %Node{value: 0, height: 1, left: nil, right: nil},
                   right: %Node{value: 2, height: 1, left: nil, right: nil}
                 },
                 right: %Node{
                   value: 5,
                   height: 2,
                   left: %Node{value: 4, height: 1, left: nil, right: nil},
                   right: nil
                 }
               },
               right: %Node{
                 value: 8,
                 height: 2,
                 left: %Node{value: 7, height: 1, left: nil, right: nil},
                 right: %Node{value: 9, height: 1, left: nil, right: nil}
               }
             }

    tree = AVLTree.delete(tree, 6)
    assert Enum.to_list(tree) == [0, 1, 2, 3, 4, 5, 7, 8, 9]
    assert AVLTree.size(tree) == 9 and AVLTree.height(tree) == 4

    #      5
    #    ┌─┴─┐
    #    3   8
    #  ┌─┴┐ ┌┴┐
    #  1  4 7 9
    # ┌┴┐
    # 0 2
    assert tree.root ==
             %Node{
               value: 5,
               height: 4,
               left: %Node{
                 value: 3,
                 height: 3,
                 left: %Node{
                   value: 1,
                   height: 2,
                   left: %Node{value: 0, height: 1, left: nil, right: nil},
                   right: %Node{value: 2, height: 1, left: nil, right: nil}
                 },
                 right: %Node{value: 4, height: 1, left: nil, right: nil}
               },
               right: %Node{
                 value: 8,
                 height: 2,
                 left: %Node{value: 7, height: 1, left: nil, right: nil},
                 right: %Node{value: 9, height: 1, left: nil, right: nil}
               }
             }

    tree = Enum.into([0, 3, 2, 1, 4, 8, 7, 9, 5, 6, 11, 12, 10, 14, 13, 15], AVLTree.new())
    tree = AVLTree.delete(tree, 4)
    assert Enum.to_list(tree) == [0, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    assert AVLTree.size(tree) == 15 and AVLTree.height(tree) == 5

    #      5
    #    ┌─┴──────┐
    #    2       11
    #  ┌─┴┐  ┌────┴──┐
    #  0  3  7      13
    # ┌┴┐   ┌┴─┐    ┌┴─┐
    #   1   6  9   12 14
    #         ┌┴─┐    ┌┴─┐
    #         8 10      15
    assert tree.root ==
             %Node{
               value: 5,
               height: 5,
               left: %Node{
                 value: 2,
                 height: 3,
                 left: %Node{
                   value: 0,
                   height: 2,
                   left: nil,
                   right: %Node{value: 1, height: 1, left: nil, right: nil}
                 },
                 right: %Node{value: 3, height: 1, left: nil, right: nil}
               },
               right: %Node{
                 value: 11,
                 height: 4,
                 left: %Node{
                   value: 7,
                   height: 3,
                   left: %Node{value: 6, height: 1, left: nil, right: nil},
                   right: %Node{
                     value: 9,
                     height: 2,
                     left: %Node{value: 8, height: 1, left: nil, right: nil},
                     right: %Node{value: 10, height: 1, left: nil, right: nil}
                   }
                 },
                 right: %Node{
                   value: 13,
                   height: 3,
                   left: %Node{value: 12, height: 1, left: nil, right: nil},
                   right: %Node{
                     value: 14,
                     height: 2,
                     left: nil,
                     right: %Node{value: 15, height: 1, left: nil, right: nil}
                   }
                 }
               }
             }

    tree = tree |> AVLTree.delete(3) |> AVLTree.delete(2)
    assert Enum.to_list(tree) == [0, 1, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]

    assert AVLTree.size(tree) == 13 and AVLTree.height(tree) == 5

    #          11
    #    ┌──────┴──┐
    #    5        13
    #  ┌─┴─┐      ┌┴─┐
    #  1   7     12 14
    # ┌┴┐ ┌┴─┐      ┌┴─┐
    # 0   6  9        15
    #       ┌┴─┐
    #       8 10
    assert tree.root ==
             %Node{
               value: 11,
               height: 5,
               left: %Node{
                 value: 5,
                 height: 4,
                 left: %Node{
                   value: 1,
                   height: 2,
                   left: %Node{value: 0, height: 1, left: nil, right: nil},
                   right: nil
                 },
                 right: %Node{
                   value: 7,
                   height: 3,
                   left: %Node{value: 6, height: 1, left: nil, right: nil},
                   right: %Node{
                     value: 9,
                     height: 2,
                     left: %Node{value: 8, height: 1, left: nil, right: nil},
                     right: %Node{value: 10, height: 1, left: nil, right: nil}
                   }
                 }
               },
               right: %Node{
                 value: 13,
                 height: 3,
                 left: %Node{value: 12, height: 1, left: nil, right: nil},
                 right: %Node{
                   value: 14,
                   height: 2,
                   left: nil,
                   right: %Node{value: 15, height: 1, left: nil, right: nil}
                 }
               }
             }
  end

  test "view" do
    tree =
      [{5, 50}, {1, 10}, {9, 90}, {1, 20}, {5, 40}, {6, 60}, {7, 70}, {2, 20}]
      |> Enum.into(AVLTree.new(fn {k1, _}, {k2, _} -> k1 < k2 end))

    assert AVLTree.view(tree) ==
             Enum.join(
               [
                 "            {5, 50}                ",
                 "       ┌───────┴───────┐           ",
                 "    {1, 20}         {6, 60}        ",
                 "   ┌───┴───┐       ┌───┴───────┐   ",
                 "{1, 10} {2, 20} {5, 40}     {9, 90}",
                 "                           ┌───┴┐  ",
                 "                        {7, 70}    "
               ],
               "\n"
             )
  end
end
