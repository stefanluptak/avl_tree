defmodule AVLTree.Node do
  @moduledoc false

  @compile {:inline,
            value: 1,
            height: 1,
            fix_height: 1,
            rotate_left: 1,
            rotate_right: 1,
            big_rotate_left: 1,
            big_rotate_right: 1,
            balance: 1}

  defstruct [:value, :height, :left, :right]

  def put(nil, value, _less), do: %__MODULE__{value: value, height: 1, left: nil, right: nil}

  def put(%__MODULE__{value: v, height: h, left: l, right: r}, value, less) do
    cond do
      less.(value, v) ->
        case put(l, value, less) do
          {:update, l} -> {:update, %__MODULE__{value: v, height: h, left: l, right: r}}
          l -> balance(%__MODULE__{value: v, height: h, left: l, right: r})
        end

      less.(v, value) ->
        case put(r, value, less) do
          {:update, r} -> {:update, %__MODULE__{value: v, height: h, left: l, right: r}}
          r -> balance(%__MODULE__{value: v, height: h, left: l, right: r})
        end

      true ->
        {:update, %__MODULE__{value: value, height: h, left: l, right: r}}
    end
  end

  def put_lower(nil, value, _less),
    do: %__MODULE__{value: value, height: 1, left: nil, right: nil}

  def put_lower(%__MODULE__{value: v, height: h, left: l, right: r}, value, less) do
    balance(
      if less.(v, value) do
        %__MODULE__{value: v, height: h, left: l, right: put_lower(r, value, less)}
      else
        %__MODULE__{value: v, height: h, left: put_lower(l, value, less), right: r}
      end
    )
  end

  def put_upper(nil, value, _less),
    do: %__MODULE__{value: value, height: 1, left: nil, right: nil}

  def put_upper(%__MODULE__{value: v, height: h, left: l, right: r}, value, less) do
    balance(
      if less.(value, v) do
        %__MODULE__{value: v, height: h, left: put_upper(l, value, less), right: r}
      else
        %__MODULE__{value: v, height: h, left: l, right: put_upper(r, value, less)}
      end
    )
  end

  def member?(nil, _value, _less), do: false

  def member?(%__MODULE__{value: v, height: _h, left: l, right: r}, value, less) do
    cond do
      less.(value, v) -> member?(l, value, less)
      less.(v, value) -> member?(r, value, less)
      true -> true
    end
  end

  def get(nil, _value, default, _less), do: default

  def get(%__MODULE__{value: v, height: _h, left: l, right: r}, value, default, less) do
    cond do
      less.(value, v) -> get(l, value, default, less)
      less.(v, value) -> get(r, value, default, less)
      true -> v
    end
  end

  def get_first(nil, default), do: default
  def get_first(%__MODULE__{value: v, height: _h, left: nil, right: _r}, _default), do: v

  def get_first(%__MODULE__{value: _v, height: _h, left: l, right: _r}, default),
    do: get_first(l, default)

  def get_last(nil, default), do: default
  def get_last(%__MODULE__{value: v, height: _h, left: _l, right: nil}, _default), do: v

  def get_last(%__MODULE__{value: _v, height: _h, left: _l, right: r}, default),
    do: get_last(r, default)

  def get_lower(nil, _value, default, _less), do: default

  def get_lower(%__MODULE__{value: v, height: _h, left: l, right: r}, value, default, less) do
    case less.(v, value) do
      true ->
        get_lower(r, value, default, less)

      false ->
        case get_lower(l, value, default, less) do
          nil ->
            case less.(value, v) do
              true -> default
              false -> v
            end

          value ->
            value
        end
    end
  end

  def get_upper(nil, _value, default, _less), do: default

  def get_upper(%__MODULE__{value: v, height: _h, left: l, right: r}, value, default, less) do
    case less.(value, v) do
      true ->
        get_upper(l, value, default, less)

      false ->
        case get_upper(r, value, default, less) do
          nil ->
            case less.(v, value) do
              true -> default
              false -> v
            end

          value ->
            value
        end
    end
  end

  def height(nil), do: 0
  def height(%__MODULE__{value: _v, height: h, left: _l, right: _r}), do: h
  def value(%__MODULE__{value: v, height: _h, left: _l, right: _r}), do: v

  def delete(nil, _value, _less), do: {false, nil}

  def delete(%__MODULE__{value: v, height: h, left: l, right: r} = a, value, less) do
    cond do
      less.(value, v) ->
        case delete(l, value, less) do
          {true, l} -> {true, balance(%__MODULE__{value: v, height: h, left: l, right: r})}
          {false, _} -> {false, a}
        end

      less.(v, value) ->
        case delete(r, value, less) do
          {true, r} -> {true, balance(%__MODULE__{value: v, height: h, left: l, right: r})}
          {false, _} -> {false, a}
        end

      true ->
        {true, delete_node(a)}
    end
  end

  def delete_lower(nil, _value, _less), do: {false, nil}

  def delete_lower(%__MODULE__{value: v, height: h, left: l, right: r} = a, value, less) do
    case less.(v, value) do
      true ->
        case delete_lower(r, value, less) do
          {true, r} -> {true, balance(%__MODULE__{value: v, height: h, left: l, right: r})}
          {false, _} -> {false, a}
        end

      false ->
        case delete_lower(l, value, less) do
          {true, l} ->
            {true, balance(%__MODULE__{value: v, height: h, left: l, right: r})}

          {false, _} ->
            case less.(value, v) do
              true -> {false, a}
              false -> {true, delete_node(a)}
            end
        end
    end
  end

  def delete_upper(nil, _value, _less), do: {false, nil}

  def delete_upper(%__MODULE__{value: v, height: h, left: l, right: r} = a, value, less) do
    case less.(value, v) do
      true ->
        case delete_upper(l, value, less) do
          {true, l} -> {true, balance(%__MODULE__{value: v, height: h, left: l, right: r})}
          {false, _} -> {false, a}
        end

      false ->
        case delete_upper(r, value, less) do
          {true, r} ->
            {true, balance(%__MODULE__{value: v, height: h, left: l, right: r})}

          {false, _} ->
            case less.(v, value) do
              true -> {false, a}
              false -> {true, delete_node(a)}
            end
        end
    end
  end

  def iter_lower(root), do: iter_lower_impl(root, [])

  def iter_lower_impl(%__MODULE__{value: _v, height: _h, left: l, right: _r} = a, iter),
    do: iter_lower_impl(l, [a | iter])

  def iter_lower_impl(nil, iter), do: iter

  def next([%__MODULE__{value: _v, height: _h, left: _, right: r} = n | tail]),
    do: {n, iter_lower_impl(r, tail)}

  def next([]), do: :none

  def view(root) do
    {_, _, canvas} = __MODULE__.View.node_view(root)
    Enum.join(canvas, "\n")
  end

  defp fix_height(%__MODULE__{value: v, height: _h, left: l, right: r}) do
    %__MODULE__{value: v, height: max(height(l), height(r)) + 1, left: l, right: r}
  end

  defp rotate_left(%__MODULE__{
         value: v,
         height: h,
         left: l,
         right: %__MODULE__{value: rv, height: rh, left: rl, right: rr}
       }) do
    fix_height(%__MODULE__{
      value: rv,
      height: rh,
      left: fix_height(%__MODULE__{value: v, height: h, left: l, right: rl}),
      right: rr
    })
  end

  defp rotate_right(%__MODULE__{
         value: v,
         height: h,
         left: %__MODULE__{value: lv, height: lh, left: ll, right: lr},
         right: r
       }) do
    fix_height(%__MODULE__{
      value: lv,
      height: lh,
      left: ll,
      right: fix_height(%__MODULE__{value: v, height: h, left: lr, right: r})
    })
  end

  defp big_rotate_left(%__MODULE__{value: v, height: h, left: l, right: r}) do
    rotate_left(%__MODULE__{value: v, height: h, left: l, right: rotate_right(r)})
  end

  defp big_rotate_right(%__MODULE__{value: v, height: h, left: l, right: r}) do
    rotate_right(%__MODULE__{value: v, height: h, left: rotate_left(l), right: r})
  end

  defp balance(a) do
    a = fix_height(a)
    %__MODULE__{value: _v, height: _h, left: l, right: r} = a

    cond do
      height(r) - height(l) == 2 ->
        %__MODULE__{value: _rv, height: _rh, left: rl, right: rr} = r

        if height(rl) <= height(rr) do
          rotate_left(a)
        else
          big_rotate_left(a)
        end

      height(l) - height(r) == 2 ->
        %__MODULE__{value: _lv, height: _lh, left: ll, right: lr} = l

        if height(lr) <= height(ll) do
          rotate_right(a)
        else
          big_rotate_right(a)
        end

      true ->
        a
    end
  end

  defp delete_node(%__MODULE__{value: _v, height: _h, left: l, right: r}) do
    if height(r) > height(l) do
      {%__MODULE__{value: v, height: h, left: _l, right: _r}, r} = delete_min(r)
      balance(%__MODULE__{value: v, height: h, left: l, right: r})
    else
      if l == nil do
        r
      else
        {%__MODULE__{value: v, height: h, left: _l, right: _r}, l} = delete_max(l)
        balance(%__MODULE__{value: v, height: h, left: l, right: r})
      end
    end
  end

  defp delete_min(%__MODULE__{value: v, height: h, left: l, right: r} = a) do
    if l do
      {m, l} = delete_min(l)
      {m, balance(%__MODULE__{value: v, height: h, left: l, right: r})}
    else
      {a, r}
    end
  end

  defp delete_max(%__MODULE__{value: v, height: h, left: l, right: r} = a) do
    if r do
      {m, r} = delete_max(r)
      {m, balance(%__MODULE__{value: v, height: h, left: l, right: r})}
    else
      {a, l}
    end
  end
end
