#
# Be sure to run `pod lib lint BABCropperView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BABCropperView"
  s.version          = "0.4.7"
  s.summary          = "A customizable image cropper view based on UIScrollView."
  s.description      = <<-DESC
                       A customizable image cropper view based on UIScrollView.
											 
											 Supports iOS 7.0+

											 * Crop size is fully configurable
											 * Allows cropping of any part of the image
											 * Fully customizable with sensible defaults
											 * Works easily with or without Auto Layout
											 * Uses memory efficient image crop which handles multiple image orientations

											 This is a UIView subclass which allows a user to crop an image to a desired size.
											 
                       DESC
  s.homepage         = "https://github.com/brynbodayle/BABCropperView"
	s.screenshots			 = "http://brynbodayle.com/Files/BABCropperView.gif"
  s.license          = 'MIT'
  s.author           = { "Bryn Bodayle" => "bryn.bodayle@gmail.com" }
  s.source           = { :git => "https://github.com/brynbodayle/BABCropperView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/brynbodayle'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
end
