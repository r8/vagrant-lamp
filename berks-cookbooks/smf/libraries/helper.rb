unless defined?(SMFManifest::Helper)
  module SMFManifest
    # Generic helper that other helpers can inherit from.
    # Takes the current node object, as well as an optional
    # resource.
    class Helper < Struct.new(:node, :resource)
    end
  end
end
