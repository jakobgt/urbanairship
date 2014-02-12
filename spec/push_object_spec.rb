require 'spec_helper'

describe Urbanairship::PushObject do
  before(:each) do
    @push_object = Urbanairship::PushObject.new
  end

  describe "#new" do
    it "takes no parameters and returns a Urbanairship::PushObject object" do
        @push_object.should be_an_instance_of Urbanairship::PushObject
    end

    context "audience" do
      context "audience identifiers" do
        context "tags" do
          context "#tag" do
            it "sets a tag" do
              po = Urbanairship::PushObject.new({ :tag => [ "tag1" ] })
              po.audience_identifiers.should == {
                :tag => [ "tag1" ]
              }
            end

            it "sets multiple tags" do
              po = Urbanairship::PushObject.new({ :tag => [ "tag1", "tag2" ] })
              po.audience_identifiers.should == {
                :tag => [ "tag1", "tag2" ]
              }
            end
          end

          context "#tags" do
            it "sets a tag" do
              po = Urbanairship::PushObject.new({ :tags => [ "tag1" ] })
              po.audience_identifiers.should == {
                :tag => [ "tag1" ]
              }
            end

            it "sets multiple tags" do
              po = Urbanairship::PushObject.new({ :tags => [ "tag1", "tag2" ] })
              po.audience_identifiers.should == {
                :tag => [ "tag1", "tag2" ]
              }
            end
          end
        end

        context "alias" do
          context "#alias" do
            it "sets a alias" do
              po = Urbanairship::PushObject.new({ :alias => [ "alias1" ] })
              po.audience_identifiers.should == {
                :alias => [ "alias1" ]
              }
            end

            it "sets multiple aliases" do
              po = Urbanairship::PushObject.new({ :alias => [ "alias1", "alias2" ] })
              po.audience_identifiers.should == {
                :alias => [ "alias1", "alias2" ]
              }
            end
          end

          context "#aliases" do
            it "sets a alias" do
              po = Urbanairship::PushObject.new({ :aliases => [ "alias1" ] })
              po.audience_identifiers.should == {
                :alias => [ "alias1" ]
              }
            end

            it "sets multiple aliases" do
              po = Urbanairship::PushObject.new({ :aliases => [ "alias1", "alias2" ] })
              po.audience_identifiers.should == {
                :alias => [ "alias1", "alias2" ]
              }
            end
          end
        end

        context "segment" do
          context "#segment" do
            it "sets a segment" do
              po = Urbanairship::PushObject.new({ :segment => [ "segment1" ] })
              po.audience_identifiers.should == {
                :segment => [ "segment1" ]
              }
            end

            it "sets multiple segmentes" do
              po = Urbanairship::PushObject.new({ :segment => [ "segment1", "segment2" ] })
              po.audience_identifiers.should == {
                :segment => [ "segment1", "segment2" ]
              }
            end
          end

          context "#segmentes" do
            it "sets a segment" do
              po = Urbanairship::PushObject.new({ :segments => [ "segment1" ] })
              po.audience_identifiers.should == {
                :segment => [ "segment1" ]
              }
            end

            it "sets multiple segmentes" do
              po = Urbanairship::PushObject.new({ :segments => [ "segment1", "segment2" ] })
              po.audience_identifiers.should == {
                :segment => [ "segment1", "segment2" ]
              }
            end
          end
        end

        context "multiple audience identifiers" do
          po = Urbanairship::PushObject.new({ :segments => [ "segment1", "segment2" ], :tag => [ "tag1" ] })
          po.audience_identifiers.should == {
                :segment => [ "segment1", "segment2" ],
                :tag => [ "tag1" ]
              }
        end
      end

      context "device identifiers" do
        it "set device identifiers for single platform" do
          po = Urbanairship::PushObject.new({ :device_token => [ "token1"] })
          po.tokens.should == {
            :device_token => [ "token1" ]
          }
        end

        it "set device identifiers for single platform (plural)" do
          po = Urbanairship::PushObject.new({ :device_tokens => [ "token1"] })
          po.tokens.should == {
            :device_token => [ "token1" ]
          }
        end

        it "set device identifiers for multiple platforms" do
          po = Urbanairship::PushObject.new({ :device_token => [ "token1"], :apid => [ "token2" ] })
          po.tokens.should == {
            :device_token => [ "token1" ],
            :apid => [ "token2" ]
          }
        end

        it "set device identifiers for multiple platforms (plural)" do
          po = Urbanairship::PushObject.new({ :device_tokens => [ "token1"], :apids => [ "token2" ] })
          po.tokens.should == {
            :device_token => [ "token1" ],
            :apid => [ "token2" ]
          }
        end
      end

      context "device and audience identifiers" do
        po = Urbanairship::PushObject.new({ :device_tokens => [ "token1"], :apids => [ "token2" ], :segment => [ "segment1" ], :tags => [ "tag1", "tag2" ] })
        po.tokens.should == {
          :device_token => [ "token1" ],
          :apid => [ "token2" ]
        }
        po.audience_identifiers.should == {
          :segment => [ "segment1" ],
          :tag => [ "tag1", "tag2" ]
        }
      end
    end

    context "overrides" do
      it "set override for single platform" do
        po = Urbanairship::PushObject.new({ :sound => "default" })
        po.overrides.should == {
          :ios => {
            :sound => "default"
          }
        }
        po.extras.should {}
      end

      it "set override for multiple platforms" do
        po = Urbanairship::PushObject.new({ :badge => 1 })
        po.overrides.should == {
          :ios => {
            :badge => 1
          },
          :wns => {
            :badge => 1
          }
        }
        po.extras.should {}
      end
    end

    it "set extras" do
      po = Urbanairship::PushObject.new({ :something => "else" })
      po.extras.should == {
        :something => "else"
      }
      po.overrides.should {}
    end

    it "set alert" do
      po = Urbanairship::PushObject.new({ :alert => "Alert Something" })
      po.alert.should eq "Alert Something"
      po.overrides.should {}
      po.extras.should {}
    end

    it "set all the things" do
      po = Urbanairship::PushObject.new({
        :alert => "Alert Something",
        :sound => "default",
        :badge => 1,
        :something => "else"
      })
      po.alert.should eq "Alert Something"
      po.overrides.should == {
        :ios => {
          :badge => 1,
          :sound => "default"
        },
        :wns => {
          :badge => 1
        }
      }
      po.extras.should == {
        :something => "else"
      }
    end
  end

  describe "#alert=" do
    it "sets the alert message" do
      @push_object.alert = "Alert Something"
      @push_object.alert.should eq "Alert Something"
    end
  end

  context "audience" do
    context "tag" do
      describe "#tag=" do
        it "sets a tag" do
          @push_object.tag = "tag1"
          @push_object.audience_identifiers.should == {
            :tag => [ "tag1" ]
          }
        end

        it "sets multiple tags" do
          @push_object.tag = [ "tag1", "tag2" ]
          @push_object.audience_identifiers.should == {
            :tag => [ "tag1", "tag2" ]
          }
        end

        it "overwrites existing tag" do
          @push_object.tag = "tag1"
          @push_object.tag = [ "tag3", "tag4" ]
          @push_object.audience_identifiers.should == {
            :tag => [ "tag3", "tag4" ]
          }
        end
      end

      describe "#tags=" do
        it "sets a tag" do
          @push_object.tags = "tag1"
          @push_object.audience_identifiers.should == {
            :tag => [ "tag1" ]
          }
        end

        it "sets multiple tags" do
          @push_object.tags = [ "tag1", "tag2" ]
          @push_object.audience_identifiers.should == {
            :tag => [ "tag1", "tag2" ]
          }
        end

        it "overwrites existing tags" do
          @push_object.tags = [ "tag1", "tag2" ]
          @push_object.tags = [ "tag3", "tag4" ]
          @push_object.audience_identifiers.should == {
            :tag => [ "tag3", "tag4" ]
          }
        end
      end

      describe "#add_tag" do
        it "adds an additional tag" do
          @push_object.tags = [ "tag1", "tag2" ]
          @push_object.add_tag("tag3")
          @push_object.audience_identifiers.should == {
            :tag => [ "tag1", "tag2", "tag3" ]
          }
        end

        it "adds additional tags" do
          @push_object.tags = [ "tag1", "tag2" ]
          @push_object.add_tag([ "tag3", "tag4" ])
          @push_object.audience_identifiers.should == {
            :tag => [ "tag1", "tag2", "tag3", "tag4" ]
          }
        end

        it "adds an initial tag" do
          @push_object.add_tag("tag1")
          @push_object.audience_identifiers.should == {
            :tag => [ "tag1" ]
          }
        end

        it "adds initial tags" do
          @push_object.add_tag([ "tag1", "tag2" ])
          @push_object.audience_identifiers.should == {
            :tag => [ "tag1", "tag2" ]
          }
        end
      end

      describe "#add_tags" do
        it "adds an additional tag" do
          @push_object.tags = [ "tag1", "tag2" ]
          @push_object.add_tags("tag3")
          @push_object.audience_identifiers.should == {
            :tag => [ "tag1", "tag2", "tag3" ]
          }
        end

        it "adds additional tags" do
          @push_object.tags = [ "tag1", "tag2" ]
          @push_object.add_tags([ "tag3", "tag4" ])
          @push_object.audience_identifiers.should == {
            :tag => [ "tag1", "tag2", "tag3", "tag4" ]
          }
        end

        it "adds an initial tag" do
          @push_object.add_tags("tag1")
          @push_object.audience_identifiers.should == {
            :tag => [ "tag1" ]
          }
        end

        it "adds initial tags" do
          @push_object.add_tags([ "tag1", "tag2" ])
          @push_object.audience_identifiers.should == {
            :tag => [ "tag1", "tag2" ]
          }
        end
      end

      describe "#tag" do
        it "retrieves the tag" do
          @push_object.tag = "tag1"
          @push_object.tag.should == [ "tag1" ]
        end

        it "retrieves the tags" do
          @push_object.tags = [ "tag1", "tag2" ]
          @push_object.tag.should == [ "tag1", "tag2" ]
        end
      end

      describe "#tags" do
        it "retrieves the tags" do
          @push_object.tag = "tag1"
          @push_object.tags.should == [ "tag1" ]
        end

        it "retrieves the tags" do
          @push_object.tags = [ "tag1", "tag2" ]
          @push_object.tags.should == [ "tag1", "tag2" ]
        end
      end
    end

    context "alias" do
      describe "#alias=" do
        it "sets an alias" do
          @push_object.alias = "alias1"
          @push_object.audience_identifiers.should == {
            :alias => [ "alias1" ]
          }
        end

        it "sets multiple aliases" do
          @push_object.alias = [ "alias1", "alias2" ]
          @push_object.audience_identifiers.should == {
            :alias => [ "alias1", "alias2" ]
          }
        end

        it "overwrites existing alias" do
          @push_object.alias = "alias1"
          @push_object.alias = [ "alias3", "alias4" ]
          @push_object.audience_identifiers.should == {
            :alias => [ "alias3", "alias4" ]
          }
        end
      end

      describe "#aliases=" do
        it "sets an alias" do
          @push_object.aliases = "alias1"
          @push_object.audience_identifiers.should == {
            :alias => [ "alias1" ]
          }
        end

        it "sets multiple aliases" do
          @push_object.aliases = [ "alias1", "alias2" ]
          @push_object.audience_identifiers.should == {
            :alias => [ "alias1", "alias2" ]
          }
        end

        it "overwrites existing aliases" do
          @push_object.aliases = [ "alias1", "alias2" ]
          @push_object.aliases = [ "alias3", "alias4" ]
          @push_object.audience_identifiers.should == {
            :alias => [ "alias3", "alias4" ]
          }
        end
      end

      describe "#add_alias" do
        it "adds an additional alias" do
          @push_object.aliases = [ "alias1", "alias2" ]
          @push_object.add_alias("alias3")
          @push_object.audience_identifiers.should == {
            :alias => [ "alias1", "alias2", "alias3" ]
          }
        end

        it "adds additional aliases" do
          @push_object.aliases = [ "alias1", "alias2" ]
          @push_object.add_alias([ "alias3", "alias4" ])
          @push_object.audience_identifiers.should == {
            :alias => [ "alias1", "alias2", "alias3", "alias4" ]
          }
        end

        it "adds an initial alias" do
          @push_object.add_alias("alias1")
          @push_object.audience_identifiers.should == {
            :alias => [ "alias1" ]
          }
        end

        it "adds initial aliases" do
          @push_object.add_alias([ "alias1", "alias2" ])
          @push_object.audience_identifiers.should == {
            :alias => [ "alias1", "alias2" ]
          }
        end
      end

      describe "#add_aliases" do
        it "adds an additional alias" do
          @push_object.aliases = [ "alias1", "alias2" ]
          @push_object.add_aliases("alias3")
          @push_object.audience_identifiers.should == {
            :alias => [ "alias1", "alias2", "alias3" ]
          }
        end

        it "adds additional aliases" do
          @push_object.aliases = [ "alias1", "alias2" ]
          @push_object.add_aliases([ "alias3", "alias4" ])
          @push_object.audience_identifiers.should == {
            :alias => [ "alias1", "alias2", "alias3", "alias4" ]
          }
        end

        it "adds an initial alias" do
          @push_object.add_aliases("alias1")
          @push_object.audience_identifiers.should == {
            :alias => [ "alias1" ]
          }
        end

        it "adds initial aliases" do
          @push_object.add_aliases([ "alias1", "alias2" ])
          @push_object.audience_identifiers.should == {
            :alias => [ "alias1", "alias2" ]
          }
        end
      end

      describe "#alias" do
        it "retrieves the alias" do
          @push_object.alias = "alias1"
          @push_object.alias.should == [ "alias1" ]
        end

        it "retrieves the aliases" do
          @push_object.alias = [ "alias1", "alias2" ]
          @push_object.alias.should == [ "alias1", "alias2" ]
        end
      end

      describe "#aliases" do
        it "retrieves the aliases" do
          @push_object.alias = "alias1"
          @push_object.aliases.should == [ "alias1" ]
        end

        it "retrieves the aliases" do
          @push_object.aliases = [ "alias1", "alias2" ]
          @push_object.aliases.should == [ "alias1", "alias2" ]
        end
      end
    end

    context "segment" do
      describe "#segment=" do
        it "sets an segment" do
          @push_object.segment = "segment1"
          @push_object.audience_identifiers.should == {
            :segment => [ "segment1" ]
          }
        end

        it "sets multiple segments" do
          @push_object.segment = [ "segment1", "segment2" ]
          @push_object.audience_identifiers.should == {
            :segment => [ "segment1", "segment2" ]
          }
        end

        it "overwrites existing segment" do
          @push_object.segment = "segment1"
          @push_object.segment = [ "segment3", "segment4" ]
          @push_object.audience_identifiers.should == {
            :segment => [ "segment3", "segment4" ]
          }
        end
      end

      describe "#segments=" do
        it "sets an segment" do
          @push_object.segments = "segment1"
          @push_object.audience_identifiers.should == {
            :segment => [ "segment1" ]
          }
        end

        it "sets multiple segments" do
          @push_object.segments = [ "segment1", "segment2" ]
          @push_object.audience_identifiers.should == {
            :segment => [ "segment1", "segment2" ]
          }
        end

        it "overwrites existing segments" do
          @push_object.segments = [ "segment1", "segment2" ]
          @push_object.segments = [ "segment3", "segment4" ]
          @push_object.audience_identifiers.should == {
            :segment => [ "segment3", "segment4" ]
          }
        end
      end

      describe "#add_segment" do
        it "adds an additional segment" do
          @push_object.segments = [ "segment1", "segment2" ]
          @push_object.add_segment("segment3")
          @push_object.audience_identifiers.should == {
            :segment => [ "segment1", "segment2", "segment3" ]
          }
        end

        it "adds additional segments" do
          @push_object.segments = [ "segment1", "segment2" ]
          @push_object.add_segment([ "segment3", "segment4" ])
          @push_object.audience_identifiers.should == {
            :segment => [ "segment1", "segment2", "segment3", "segment4" ]
          }
        end

        it "adds an initial segment" do
          @push_object.add_segment("segment1")
          @push_object.audience_identifiers.should == {
            :segment => [ "segment1" ]
          }
        end

        it "adds initial segments" do
          @push_object.add_segment([ "segment1", "segment2" ])
          @push_object.audience_identifiers.should == {
            :segment => [ "segment1", "segment2" ]
          }
        end
      end

      describe "#add_segments" do
        it "adds an additional segment" do
          @push_object.segments = [ "segment1", "segment2" ]
          @push_object.add_segments("segment3")
          @push_object.audience_identifiers.should == {
            :segment => [ "segment1", "segment2", "segment3" ]
          }
        end

        it "adds additional segments" do
          @push_object.segments = [ "segment1", "segment2" ]
          @push_object.add_segments([ "segment3", "segment4" ])
          @push_object.audience_identifiers.should == {
            :segment => [ "segment1", "segment2", "segment3", "segment4" ]
          }
        end

        it "adds an initial segment" do
          @push_object.add_segments("segment1")
          @push_object.audience_identifiers.should == {
            :segment => [ "segment1" ]
          }
        end

        it "adds initial segments" do
          @push_object.add_segments([ "segment1", "segment2" ])
          @push_object.audience_identifiers.should == {
            :segment => [ "segment1", "segment2" ]
          }
        end
      end

      describe "#segment" do
        it "retrieves the segment" do
          @push_object.segment = "segment1"
          @push_object.segment.should == [ "segment1" ]
        end

        it "retrieves the segments" do
          @push_object.segment = [ "segment1", "segment2" ]
          @push_object.segment.should == [ "segment1", "segment2" ]
        end
      end

      describe "#segments" do
        it "retrieves the segments" do
          @push_object.segment = "segment1"
          @push_object.segments.should == [ "segment1" ]
        end

        it "retrieves the segments" do
          @push_object.segments = [ "segment1", "segment2" ]
          @push_object.segments.should == [ "segment1", "segment2" ]
        end
      end
    end

    context "device identifiers" do
      # the ios context is the primary testing context,
      # the other contexts are for testing the individual identifiers

      context "ios" do
        describe "#device_tokens=" do
          it "takes takes one device token" do
            @push_object.device_tokens = "token1"
            @push_object.tokens.should == {
              :device_token => [ "token1" ]
            }
          end

          it "takes takes multiple device token" do
            @push_object.device_tokens = [ "token1", "token2" ]
            @push_object.tokens.should == {
              :device_token => [ "token1", "token2" ]
            }
          end

          it "overwrites current device tokens" do
            @push_object.device_tokens = [ "token1", "token2" ]
            @push_object.device_tokens = "token3"
            @push_object.tokens.should == {
              :device_token => [ "token3" ]
            }
          end
        end

        describe "#device_tokens" do
          it "retrieves device tokens" do
            @push_object.device_token = "token1"
            @push_object.device_token.should == [ "token1" ]
          end

          it "retrieves device tokens" do
            @push_object.device_tokens = [ "token1", "token2" ]
            @push_object.device_tokens.should == [ "token1", "token2" ]
          end
        end

        describe "#add_device_tokens" do
          it "add an additional device tokens" do
            @push_object.device_tokens = [ "token1", "token2" ]
            @push_object.add_device_tokens("token3")
            @push_object.tokens.should == {
              :device_token => [ "token1", "token2", "token3" ]
            }
          end

          it "add multiple additional device tokens" do
            @push_object.device_tokens = [ "token1", "token2" ]
            @push_object.add_device_tokens([ "token3", "token4" ])
            @push_object.tokens.should == {
              :device_token => [ "token1", "token2", "token3", "token4" ]
            }
          end

          it "add single initial device tokens" do
            @push_object.add_device_tokens("token1")
            @push_object.tokens.should == {
              :device_token => [ "token1" ]
            }
          end
        end
      end

      context "android" do
        describe "#apids=" do
          it "takes takes one apid" do
            @push_object.apids = "token1"
            @push_object.tokens.should == {
              :apid => [ "token1" ]
            }
          end
        end

        describe "#apids" do
          it "retrieves apids" do
            @push_object.apid = "token1"
            @push_object.apid.should == [ "token1" ]
          end

          it "retrieves apids" do
            @push_object.apids = [ "token1", "token2" ]
            @push_object.apids.should == [ "token1", "token2" ]
          end
        end

        describe "#add_device_tokens" do
          it "add an additional apid" do
            @push_object.apids = [ "token1", "token2" ]
            @push_object.add_apids("token3")
            @push_object.tokens.should == {
              :apid => [ "token1", "token2", "token3" ]
            }
          end
        end
      end

      context "blackberry" do
        describe "#device_pins=" do
          it "takes takes one device pin" do
            @push_object.device_pins = "token1"
            @push_object.tokens.should == {
              :device_pin => [ "token1" ]
            }
          end
        end

        describe "#device_pins" do
          it "retrieves device pins" do
            @push_object.device_pin = "token1"
            @push_object.device_pin.should == [ "token1" ]
          end

          it "retrieves device pins" do
            @push_object.device_pins = [ "token1", "token2" ]
            @push_object.device_pins.should == [ "token1", "token2" ]
          end
        end

        describe "#add_device_pins" do
          it "add an additional device pin" do
            @push_object.device_pins = [ "token1", "token2" ]
            @push_object.add_device_pins("token3")
            @push_object.tokens.should == {
              :device_pin => [ "token1", "token2", "token3" ]
            }
          end
        end
      end

      context "mpns" do
        describe "#mpns=" do
          it "takes takes one mpns" do
            @push_object.mpns = "token1"
            @push_object.tokens.should == {
              :mpns => [ "token1" ]
            }
          end
        end

        describe "#mpns" do
          it "retrieves the mpns token" do
            @push_object.mpns = "token1"
            @push_object.mpns.should == [ "token1" ]
          end

          it "retrieves the mpns tokens" do
            @push_object.mpnss = [ "token1", "token2" ]
            @push_object.mpnss.should == [ "token1", "token2" ]
          end
        end

        describe "#add_mpns" do
          it "add an additional mpns" do
            @push_object.mpns = [ "token1", "token2" ]
            @push_object.add_mpns("token3")
            @push_object.tokens.should == {
              :mpns => [ "token1", "token2", "token3" ]
            }
          end
        end
      end

      context "wns" do
        describe "#wns=" do
          it "takes takes one wns" do
            @push_object.wns = "token1"
            @push_object.tokens.should == {
              :wns => [ "token1" ]
            }
          end
        end

        describe "#wns" do
          it "retrieves the wns token" do
            @push_object.wns = "token1"
            @push_object.wns.should == [ "token1" ]
          end

          it "retrieves the wns tokens" do
            @push_object.wnss = [ "token1", "token2" ]
            @push_object.wnss.should == [ "token1", "token2" ]
          end
        end

        describe "#add_wns" do
          it "add an additional wns" do
            @push_object.wns = [ "token1", "token2" ]
            @push_object.add_wns("token3")
            @push_object.tokens.should == {
              :wns => [ "token1", "token2", "token3" ]
            }
          end
        end
      end

      context "multiple platforms" do
        it "sets device identifiers for multiple platforms" do
          @push_object.device_tokens = "token1"
          @push_object.apids = [ "token2", "token3" ]
          @push_object.tokens.should == {
            :device_token => [ "token1" ],
            :apid => [ "token2", "token3" ]
          }
        end
      end
    end
  end

  context "overrides and extras" do
    context "overrides" do
      context "set directly" do
        it "sets the override on the specified platform" do
          @push_object.add_platform_override(:ios, :badge, 1)
          @push_object.overrides.should == {
            :ios => {
              :badge => 1
            }
          }
        end

        it "does not set an override for a non-existent platform" do
          @push_object.add_platform_override(:bad_platform, :badge, 1)
          @push_object.overrides.should == {}
        end

        it "does not set an override if the override is not defined for the platform" do
          @push_object.add_platform_override(:ios, :bad_override, 1)
          @push_object.overrides.should == {}
        end
      end

      context "via method missing" do
        it "identifies and sets single platform override" do
          @push_object.sound = "default"
          @push_object.overrides.should == {
            :ios => {
              :sound => "default"
            }
          }
        end

        it "identifies and sets multiple overrides for a single platform" do
          @push_object.sound = "default"
          @push_object.priority = 7
          @push_object.overrides.should == {
            :ios => {
              :sound => "default",
              :priority => 7
            }
          }
        end

        it "identifies and sets overrides for multiple platforms" do
          @push_object.sound = "default"
          @push_object.collapse_key = "unique_key"
          @push_object.priority = 7
          @push_object.overrides.should == {
            :ios => {
              :sound => "default",
              :priority => 7
            },
            :android => {
              :collapse_key => "unique_key"
            }
          }
        end
      end
    end

    context "extras" do
      context "set directly" do
        it "adds an extra" do
          @push_object.add_extra(:something, "else")
          @push_object.extras.should == {
            :something => "else"
          }
        end

        it "converts number to string" do
          @push_object.something = 1
          @push_object.extras.should == {
            :something => "1"
          }
        end
      end

      context "via method missing" do
        it "adds an extra" do
          @push_object.something = "else"
          @push_object.extras.should == {
            :something => "else"
          }
        end

        it "retrieves extra" do
          @push_object.something = "else"
          @push_object.something.should == "else"
        end
      end
    end
  end

  describe "#build" do
    it "sets the alert message" do
      @push_object.alert = "Alert subject"
      @push_object.build.should == {
        :audience => nil,
        :notification => {
          :alert => "Alert subject"
        }
      }
    end

    context "device identifiers" do
      it "sets the ios device tokens" do
        @push_object.device_tokens = "token1"
        @push_object.build.should == {
          :audience => {
            :device_token => [ "token1" ]
          },
          :notification => {
            :alert => nil
          },
          :device_types =>[ :ios ]
        }
      end

      it "sets the android apid" do
        @push_object.apids = "token1"
        @push_object.build.should == {
          :audience => {
            :apid => [ "token1" ]
          },
          :notification => {
            :alert => nil
          },
          :device_types =>[ :android ]
        }
      end

      it "sets device identifiers for multiple platforms" do
        @push_object.device_tokens = "token1"
        @push_object.apids = "token2"
        @push_object.build.should == {
          :audience => {
            :OR => [
              { :apid => [ "token2" ] },
              { :device_token => [ "token1" ] }
            ]
          },
          :notification => {
            :alert => nil
          },
          :device_types =>[ :android, :ios ]
        }
      end
    end

    context "audience identifiers" do
      context "tags" do
        it "set tag" do
          @push_object.tag = "tag1"
          @push_object.build.should == {
            :audience => {
              :tag => [ "tag1" ]
            },
            :notification => {
              :alert => nil
            }
          }
        end

        it "set tags" do
          @push_object.tags = [ "tag1", "tag2" ]
          @push_object.build.should == {
            :audience => {
              :tag => [ "tag1", "tag2" ]
            },
            :notification => {
              :alert => nil
            }
          }
        end
      end

      context "aliases" do
        it "set alias" do
          @push_object.alias = "alias1"
          @push_object.build.should == {
            :audience => {
              :alias => [ "alias1" ]
            },
            :notification => {
              :alert => nil
            }
          }
        end

        it "set aliases" do
          @push_object.aliases = [ "alias1", "alias2" ]
          @push_object.build.should == {
            :audience => {
              :alias => [ "alias1", "alias2" ]
            },
            :notification => {
              :alert => nil
            }
          }
        end
      end

      context "segments" do
        it "set segment" do
          @push_object.segment = "segment1"
          @push_object.build.should == {
            :audience => {
              :segment => [ "segment1" ]
            },
            :notification => {
              :alert => nil
            }
          }
        end

        it "set segments" do
          @push_object.segments = [ "segment1", "segment2" ]
          @push_object.build.should == {
            :audience => {
              :segment => [ "segment1", "segment2" ]
            },
            :notification => {
              :alert => nil
            }
          }
        end
      end

      context "multiple audience identifiers" do
        it "set segment and tag" do
          @push_object.segment = "segment1"
          @push_object.tag = "tag1"
          @push_object.build.should == {
            :audience => {
              :OR => [
                { :segment => [ "segment1" ] },
                { :tag => [ "tag1" ] }
              ]
            },
            :notification => {
              :alert => nil
            }
          }
        end
      end

      context "audience identifiers and device identifiers" do
        it "set segment and tag" do
          @push_object.segment = "segment1"
          @push_object.tag = "tag1"
          @push_object.apid = "apid1"
          @push_object.device_token = "device_token1"
          @push_object.build.should == {
            :audience => {
              :OR => [
                { :apid => [ "apid1" ] },
                { :device_token => [ "device_token1" ] },
                { :segment => [ "segment1" ] },
                { :tag => [ "tag1" ] }
              ]
            },
            :notification => {
              :alert => nil
            },
            :device_types =>[ :android, :ios ]
          }
        end
      end
    end

    context "overrides" do
      context "set directly" do
        it "adds override to a specified platform" do
          @push_object.device_tokens = [ "token1" ]
          @push_object.add_platform_override(:ios, :badge, 1)
          @push_object.build.should == {
            :audience => {
              :device_token => [ "token1" ]
            },
            :notification => {
              :alert => nil,
              :ios => {
                :badge => 1
              }
            },
            :device_types =>[ :ios ]
          }
        end

        it "does not add override to an unused platform" do
          @push_object.apids = [ "token1" ]
          @push_object.add_platform_override(:ios, :badge, 1)
          @push_object.build.should == {
            :audience => {
              :apid => [ "token1" ]
            },
            :notification => {
              :alert => nil
            },
            :device_types =>[ :android ]
          }
        end
      end

      context "method missing overrides" do
        it "adds override to a single platform" do
          @push_object.device_tokens = [ "token1" ]
          @push_object.badge = 1
          @push_object.build.should == {
            :audience => {
              :device_token => [ "token1" ]
            },
            :notification => {
              :alert => nil,
              :ios => {
                :badge => 1
              }
            },
            :device_types =>[ :ios ]
          }
        end

        it "adds overrides to multipe platforms" do
          @push_object.device_tokens = [ "token1" ]
          @push_object.wns = [ "token2" ]
          @push_object.apids = [ "token3" ]
          @push_object.badge = 1
          @push_object.build.should == {
            :audience => {
              :OR => [
                { :apid => [ "token3" ] },
                { :device_token => [ "token1" ] },
                { :wns => [ "token2" ] }
              ]
            },
            :notification => {
              :alert => nil,
              :ios => {
                :badge => 1
              },
              :wns => {
                :badge => 1
              }
            },
            :device_types =>[ :android, :ios, :wns ]
          }
        end

        it "only adds platform overrides for present device types" do
          @push_object.device_tokens = [ "token1" ]
          @push_object.apids = [ "token2" ]
          @push_object.badge = 1
          @push_object.build.should == {
            :audience => {
              :OR => [
                { :apid => [ "token2" ] },
                { :device_token => [ "token1" ] }
              ]
            },
            :notification => {
              :alert => nil,
              :ios => {
                :badge => 1
              }
            },
            :device_types =>[ :android, :ios ]
          }
        end
      end
    end

    context "extras" do
      it "doesn't add extras if empty" do
        @push_object.device_tokens = [ "token1" ]
        @push_object.build.should == {
          :audience => {
            :device_token => [ "token1" ]
          },
          :notification => {
            :alert => nil
          },
          :device_types =>[ :ios ]
        }
      end

      it "adds extras to platforms which allow it" do
        @push_object.device_tokens = [ "token1" ]
        @push_object.apids = [ "token2" ]
        @push_object.something = "else"
        @push_object.build.should == {
          :audience => {
            :OR => [
              { :apid => [ "token2" ] },
              { :device_token => [ "token1" ] }
            ]
          },
          :notification => {
            :alert => nil,
            :ios => {
              :extra => {
                :something => "else"
              }
            },
            :android => {
              :extra => {
                :something => "else"
              }
            }
          },
          :device_types =>[ :android, :ios ]
        }
      end

      it "doesn't add extras to platforms which do not allow it" do
        @push_object.device_tokens = [ "token1" ]
        @push_object.mpns = [ "token2" ]
        @push_object.something = "else"
        @push_object.build.should == {
          :audience => {
            :OR => [
              { :device_token => [ "token1" ] },
              { :mpns => [ "token2" ] }
            ]
          },
          :notification => {
            :alert => nil,
            :ios => {
              :extra => {
                :something => "else"
              }
            }
          },
          :device_types =>[ :ios, :mpns ]
        }
      end
    end
  end

end
