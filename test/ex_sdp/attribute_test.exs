defmodule ExSDP.AttributeTest do
  use ExUnit.Case

  alias ExSDP.Attribute

  describe "Attribute parser" do
    test "handles integer framerate" do
      assert {:ok, {:framerate, 30.0}} = Attribute.parse("framerate:30")
    end

    test "handles decimal framerate" do
      assert {:ok, {:framerate, 30.0}} = Attribute.parse("framerate:30.0")
    end

    test "handles framerate" do
      assert {:ok, {:framerate, {30, 1}}} = Attribute.parse("framerate:30/1")
    end

    test "handles broadcast type" do
      assert {:ok, {:type, :broadcast}} = Attribute.parse("type:broadcast")
    end

    test "handles directly assignable attributes" do
      assert {:ok, {:cat, "category"}} = Attribute.parse("cat:category")
    end

    test "handles known integer attributes" do
      assert {:ok, {:quality, 7}} = Attribute.parse("quality:7")
    end

    test "returns an error if attribute supposed to be numeric but isn't" do
      assert {:error, :invalid_attribute} = Attribute.parse("ptime:g7")
    end

    test "handles known flags" do
      assert {:ok, :recvonly} = Attribute.parse("recvonly")
    end

    test "handles unknown attribute" do
      assert {:ok, "otherattr"} = Attribute.parse("otherattr")
    end
  end
end
