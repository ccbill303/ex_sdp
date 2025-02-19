defmodule ExSDP.RFCTest do
  @moduledoc """
  This test suit contains specs from RFC [4566](https://tools.ietf.org/html/rfc4566)
  and [4317](https://tools.ietf.org/html/rfc4317)
  that should be parsed by this parser.
  """
  use ExUnit.Case

  alias ExSDP

  alias ExSDP.{
    Attribute,
    ConnectionData,
    Media,
    Origin,
    Timing
  }

  describe "SDP parser processes SDP specs from RFC" do
    @tag integration: true
    test "Parses single media spec with flag attributes" do
      assert {:ok, session_spec} =
               """
               v=0
               o=jdoe 2890844526 2890842807 IN IP4 10.47.16.5
               s=SDP Seminar
               i=A Seminar on the session description protocol
               u=http://www.example.com/seminars/sdp.pdf
               e=j.doe@example.com (Jane Doe)
               c=IN IP4 224.2.17.12/127
               t=2873397496 2873404696
               a=recvonly
               m=audio 49170 RTP/AVP 0
               m=video 51372 RTP/AVP 99
               a=rtpmap:99 h263-1998/90000
               """
               |> String.replace("\n", "\r\n")
               |> ExSDP.parse()

      assert session_spec == %ExSDP{
               attributes: [:recvonly],
               connection_data: %ConnectionData{ttl: 127, address: {224, 2, 17, 12}},
               email: "j.doe@example.com (Jane Doe)",
               media: [
                 %Media{
                   attributes: [],
                   bandwidth: [],
                   connection_data: %ConnectionData{ttl: 127, address: {224, 2, 17, 12}},
                   fmt: [0],
                   port: 49_170,
                   protocol: "RTP/AVP",
                   type: :audio
                 },
                 %Media{
                   attributes: [
                     {:rtpmap,
                      %Attribute.RTPMapping{
                        clock_rate: 90_000,
                        encoding: "h263-1998",
                        payload_type: 99
                      }}
                   ],
                   connection_data: %ConnectionData{ttl: 127, address: {224, 2, 17, 12}},
                   fmt: [99],
                   port: 51_372,
                   protocol: "RTP/AVP",
                   type: :video
                 }
               ],
               origin: %Origin{
                 address: {10, 47, 16, 5},
                 session_id: 2_890_844_526,
                 session_version: 2_890_842_807,
                 username: "jdoe"
               },
               session_information: "A Seminar on the session description protocol",
               session_name: "SDP Seminar",
               timing: %Timing{
                 start_time: 2_873_397_496,
                 stop_time: 2_873_404_696
               },
               uri: "http://www.example.com/seminars/sdp.pdf",
               version: 0
             }
    end

    @tag integration: true
    test "parses audio and video offer" do
      assert {:ok, result} =
               """
               v=0
               o=alice 2890844526 2890844526 IN IP4 host.atlanta.example.com
               s=SDP Seminar
               c=IN IP4 host.atlanta.example.com
               t=0 0
               m=audio 49170 RTP/AVP 0 8 97
               a=rtpmap:0 PCMU/8000
               a=rtpmap:8 PCMA/8000
               a=rtpmap:97 iLBC/8000
               m=video 51372 RTP/AVP 31 32
               a=rtpmap:31 H261/90000
               a=rtpmap:32 MPV/90000
               """
               |> String.replace("\n", "\r\n")
               |> ExSDP.parse()

      assert result == %ExSDP{
               attributes: [],
               bandwidth: [],
               connection_data: %ConnectionData{address: {:IP4, "host.atlanta.example.com"}},
               email: nil,
               encryption: nil,
               media: [
                 %Media{
                   attributes: [
                     {:rtpmap,
                      %Attribute.RTPMapping{
                        clock_rate: 8000,
                        encoding: "PCMU",
                        params: 1,
                        payload_type: 0
                      }},
                     {:rtpmap,
                      %Attribute.RTPMapping{
                        clock_rate: 8000,
                        encoding: "PCMA",
                        params: 1,
                        payload_type: 8
                      }},
                     {:rtpmap,
                      %Attribute.RTPMapping{
                        clock_rate: 8000,
                        encoding: "iLBC",
                        params: 1,
                        payload_type: 97
                      }}
                   ],
                   bandwidth: [],
                   connection_data: %ConnectionData{address: {:IP4, "host.atlanta.example.com"}},
                   encryption: nil,
                   fmt: [0, 8, 97],
                   port: 49_170,
                   protocol: "RTP/AVP",
                   title: nil,
                   type: :audio
                 },
                 %Media{
                   attributes: [
                     {:rtpmap,
                      %Attribute.RTPMapping{
                        clock_rate: 90_000,
                        encoding: "H261",
                        payload_type: 31
                      }},
                     {:rtpmap,
                      %Attribute.RTPMapping{
                        clock_rate: 90_000,
                        encoding: "MPV",
                        payload_type: 32
                      }}
                   ],
                   bandwidth: [],
                   connection_data: %ConnectionData{address: {:IP4, "host.atlanta.example.com"}},
                   encryption: nil,
                   fmt: [31, 32],
                   port: 51_372,
                   protocol: "RTP/AVP",
                   title: nil,
                   type: :video
                 }
               ],
               origin: %Origin{
                 address: {:IP4, "host.atlanta.example.com"},
                 session_id: 2_890_844_526,
                 session_version: 2_890_844_526,
                 username: "alice"
               },
               phone_number: nil,
               session_information: nil,
               session_name: "SDP Seminar",
               time_repeats: [],
               time_zones_adjustments: nil,
               timing: %Timing{start_time: 0, stop_time: 0},
               uri: nil,
               version: 0
             }
    end

    @tag integration: true
    test "parses audio and video answer" do
      assert {:ok, result} =
               """
               v=0
               o=bob 2808844564 2808844564 IN IP4 host.biloxi.example.com
               s=SDP Seminar
               c=IN IP4 host.biloxi.example.com
               t=0 0
               m=audio 49174 RTP/AVP 0
               a=rtpmap:0 PCMU/8000
               m=video 49170 RTP/AVP 32
               a=rtpmap:32 MPV/90000
               """
               |> String.replace("\n", "\r\n")
               |> ExSDP.parse()

      assert %ExSDP{
               attributes: [],
               bandwidth: [],
               connection_data: %ConnectionData{address: {:IP4, "host.biloxi.example.com"}},
               email: nil,
               encryption: nil,
               media: [
                 %Media{
                   attributes: [
                     {:rtpmap,
                      %Attribute.RTPMapping{
                        clock_rate: 8000,
                        encoding: "PCMU",
                        params: 1,
                        payload_type: 0
                      }}
                   ],
                   bandwidth: [],
                   connection_data: %ConnectionData{address: {:IP4, "host.biloxi.example.com"}},
                   encryption: nil,
                   fmt: [0],
                   port: 49_174,
                   protocol: "RTP/AVP",
                   title: nil,
                   type: :audio
                 },
                 %Media{
                   attributes: [
                     {:rtpmap,
                      %Attribute.RTPMapping{
                        clock_rate: 90_000,
                        encoding: "MPV",
                        payload_type: 32,
                        params: nil
                      }}
                   ],
                   bandwidth: [],
                   connection_data: %ConnectionData{address: {:IP4, "host.biloxi.example.com"}},
                   encryption: nil,
                   fmt: [32],
                   port: 49_170,
                   protocol: "RTP/AVP",
                   title: nil,
                   type: :video
                 }
               ],
               origin: %Origin{
                 username: "bob",
                 session_id: 2_808_844_564,
                 session_version: 2_808_844_564,
                 address: {:IP4, "host.biloxi.example.com"}
               },
               phone_number: nil,
               session_information: nil,
               session_name: "SDP Seminar",
               time_repeats: [],
               time_zones_adjustments: nil,
               timing: %Timing{start_time: 0, stop_time: 0},
               uri: nil,
               version: 0
             } = result
    end
  end

  describe "SDP serializer serializes SDP specs from RFC" do
    @tag integration: true
    test "Serializes single media spec with flag attributes" do
      expected =
        """
        v=0
        o=jdoe 2890844526 2890842807 IN IP4 10.47.16.5
        s=SDP Seminar
        i=A Seminar on the session description protocol
        u=http://www.example.com/seminars/sdp.pdf
        e=j.doe@example.com (Jane Doe)
        c=IN IP4 224.2.17.12/127
        t=2873397496 2873404696
        a=recvonly
        m=audio 49170 RTP/AVP 0
        m=video 51372 RTP/AVP 99
        a=rtpmap:99 h263-1998/90000
        """
        |> String.replace("\n", "\r\n")

      assert expected ==
               to_string(%ExSDP{
                 attributes: [:recvonly],
                 connection_data: %ConnectionData{ttl: 127, address: {224, 2, 17, 12}},
                 email: "j.doe@example.com (Jane Doe)",
                 media: [
                   %Media{
                     attributes: [],
                     bandwidth: [],
                     fmt: [0],
                     port: 49_170,
                     protocol: "RTP/AVP",
                     type: :audio
                   },
                   %Media{
                     attributes: [
                       {:rtpmap,
                        %Attribute.RTPMapping{
                          clock_rate: 90_000,
                          encoding: "h263-1998",
                          payload_type: 99
                        }}
                     ],
                     fmt: [99],
                     port: 51_372,
                     protocol: "RTP/AVP",
                     type: :video
                   }
                 ],
                 origin: %Origin{
                   address: {10, 47, 16, 5},
                   session_id: 2_890_844_526,
                   session_version: 2_890_842_807,
                   username: "jdoe"
                 },
                 session_information: "A Seminar on the session description protocol",
                 session_name: "SDP Seminar",
                 timing: %Timing{
                   start_time: 2_873_397_496,
                   stop_time: 2_873_404_696
                 },
                 uri: "http://www.example.com/seminars/sdp.pdf",
                 version: 0
               })
    end

    @tag integration: true
    test "serializes audio and video offer" do
      expected =
        """
        v=0
        o=alice 2890844526 2890844526 IN IP4 host.atlanta.example.com
        s=SDP Seminar
        c=IN IP4 host.atlanta.example.com
        t=0 0
        m=audio 49170 RTP/AVP 0 8 97
        a=rtpmap:0 PCMU/8000
        a=rtpmap:8 PCMA/8000
        a=rtpmap:97 iLBC/8000
        m=video 51372 RTP/AVP 31 32
        a=rtpmap:31 H261/90000
        a=rtpmap:32 MPV/90000
        """
        |> String.replace("\n", "\r\n")

      assert expected ==
               to_string(%ExSDP{
                 attributes: [],
                 bandwidth: [],
                 connection_data: %ConnectionData{address: {:IP4, "host.atlanta.example.com"}},
                 email: nil,
                 encryption: nil,
                 media: [
                   %Media{
                     attributes: [
                       {:rtpmap,
                        %Attribute.RTPMapping{
                          clock_rate: 8000,
                          encoding: "PCMU",
                          params: 1,
                          payload_type: 0
                        }},
                       {:rtpmap,
                        %Attribute.RTPMapping{
                          clock_rate: 8000,
                          encoding: "PCMA",
                          params: 1,
                          payload_type: 8
                        }},
                       {:rtpmap,
                        %Attribute.RTPMapping{
                          clock_rate: 8000,
                          encoding: "iLBC",
                          params: 1,
                          payload_type: 97
                        }}
                     ],
                     bandwidth: [],
                     encryption: nil,
                     fmt: [0, 8, 97],
                     port: 49_170,
                     protocol: "RTP/AVP",
                     title: nil,
                     type: :audio
                   },
                   %Media{
                     attributes: [
                       {:rtpmap,
                        %Attribute.RTPMapping{
                          clock_rate: 90_000,
                          encoding: "H261",
                          payload_type: 31
                        }},
                       {:rtpmap,
                        %Attribute.RTPMapping{
                          clock_rate: 90_000,
                          encoding: "MPV",
                          payload_type: 32
                        }}
                     ],
                     bandwidth: [],
                     encryption: nil,
                     fmt: [31, 32],
                     port: 51_372,
                     protocol: "RTP/AVP",
                     title: nil,
                     type: :video
                   }
                 ],
                 origin: %Origin{
                   address: {:IP4, "host.atlanta.example.com"},
                   session_id: 2_890_844_526,
                   session_version: 2_890_844_526,
                   username: "alice"
                 },
                 phone_number: nil,
                 session_information: nil,
                 session_name: "SDP Seminar",
                 time_repeats: [],
                 time_zones_adjustments: nil,
                 timing: %Timing{start_time: 0, stop_time: 0},
                 uri: nil,
                 version: 0
               })
    end

    @tag integration: true
    test "serializes audio and video answer" do
      expected =
        """
        v=0
        o=bob 2808844564 2808844564 IN IP4 host.biloxi.example.com
        s=SDP Seminar
        c=IN IP4 host.biloxi.example.com
        t=0 0
        m=audio 49174 RTP/AVP 0
        a=rtpmap:0 PCMU/8000
        m=video 49170 RTP/AVP 32
        a=rtpmap:32 MPV/90000
        """
        |> String.replace("\n", "\r\n")

      assert expected ==
               to_string(%ExSDP{
                 attributes: [],
                 bandwidth: [],
                 connection_data: %ConnectionData{address: {:IP4, "host.biloxi.example.com"}},
                 email: nil,
                 encryption: nil,
                 media: [
                   %Media{
                     attributes: [
                       {:rtpmap,
                        %Attribute.RTPMapping{
                          clock_rate: 8000,
                          encoding: "PCMU",
                          params: 1,
                          payload_type: 0
                        }}
                     ],
                     bandwidth: [],
                     encryption: nil,
                     fmt: [0],
                     port: 49_174,
                     protocol: "RTP/AVP",
                     title: nil,
                     type: :audio
                   },
                   %Media{
                     attributes: [
                       {:rtpmap,
                        %Attribute.RTPMapping{
                          clock_rate: 90_000,
                          encoding: "MPV",
                          payload_type: 32,
                          params: nil
                        }}
                     ],
                     bandwidth: [],
                     encryption: nil,
                     fmt: [32],
                     port: 49_170,
                     protocol: "RTP/AVP",
                     title: nil,
                     type: :video
                   }
                 ],
                 origin: %Origin{
                   username: "bob",
                   session_id: 2_808_844_564,
                   session_version: 2_808_844_564,
                   address: {:IP4, "host.biloxi.example.com"}
                 },
                 phone_number: nil,
                 session_information: nil,
                 session_name: "SDP Seminar",
                 time_repeats: [],
                 time_zones_adjustments: nil,
                 timing: %Timing{start_time: 0, stop_time: 0},
                 uri: nil,
                 version: 0
               })
    end
  end
end
