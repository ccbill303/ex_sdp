defmodule ExSDP.Attribute.FMTPTest do
  use ExUnit.Case

  alias ExSDP.Attribute.FMTP

  describe "FMTP parser" do
    test "parses fmtp" do
      fmtp = "108 profile-level-id=42e01f;level-asymmetry-allowed=1;packetization-mode=1"

      expected = %FMTP{
        pt: 108,
        profile_level_id: 0x42E01F,
        level_asymmetry_allowed: true,
        packetization_mode: 1
      }

      assert {:ok, expected} == FMTP.parse(fmtp)
    end

    test "parses fmtp with sprop-parameter-sets" do
      fmtp =
        "96 profile-level-id=4d0029;packetization-mode=1;sprop-parameter-sets=Z00AKeKQCgC3YC3AQEBpB4kRUA==,a048gA=="

      expected = %FMTP{
        pt: 96,
        profile_level_id: 0x4D0029,
        packetization_mode: 1,
        sprop_parameter_sets: "Z00AKeKQCgC3YC3AQEBpB4kRUA==,a048gA=="
      }

      assert {:ok, expected} == FMTP.parse(fmtp)
    end

    test "returns an error when there is unsupported parameter" do
      fmtp = "108 profile-level-id=42e01f;level-asymmetry-allowed=1;unsupported-param=1"
      assert {:error, :unsupported_parameter} = FMTP.parse(fmtp)
    end
  end

  describe "FMTP serializer" do
    test "serializes FMTP with numeric and boolean values" do
      fmtp = %FMTP{
        pt: 120,
        minptime: 10,
        useinbandfec: true
      }

      assert "#{fmtp}" == "fmtp:120 minptime=10;useinbandfec=1"
    end

    test "serializes FMTP with hexadecimal numeric values and boolean values" do
      expected = "fmtp:108 profile-level-id=42e01f;level-asymmetry-allowed=1;packetization-mode=1"

      fmtp = %FMTP{
        pt: 108,
        profile_level_id: 0x42E01F,
        level_asymmetry_allowed: true,
        packetization_mode: 1
      }

      assert "#{fmtp}" == expected
    end
  end
end
