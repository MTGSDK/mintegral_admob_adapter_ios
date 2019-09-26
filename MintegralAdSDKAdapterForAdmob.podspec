Pod::Spec.new do |spec|


  spec.name         = 'MintegralAdSDKAdapterForAdmob'
  spec.version      = '5.7.1.0'
  spec.summary      = 'Mintegral Network CustomEvent for Admob Ad Mediation'
  spec.homepage     = 'http://cdn-adn.rayjump.com/cdn-adn/v2/markdown_v2/index.html?file=sdk-m_sdk-ios&lang=en'
  spec.description  = <<-DESC   
    Mintegral's  AdSDK allows you to monetize your iOS and Android apps with Mintegral ads. And this CustomEvent  for use Mintegral via Admob sdk 
                       DESC

  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author             = 'Mintegral'
  spec.social_media_url   = 'https://www.facebook.com/mintegral.official'
  spec.platform     = :ios, '8.0'
  spec.source       = { :git => 'https://github.com/Mintegral-official/mintegral_admob_adapter_ios.git', :tag => spec.version}
  spec.requires_arc = true
  spec.static_framework = true



# ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
spec.default_subspecs =  'NativeAdAdapter'

spec.subspec 'NativeAdAdapter' do |ss|

  ss.dependency 'Google-Mobile-Ads-SDK', '~> 7.27.0'
  ss.dependency  'MintegralAdSDK/NativeAd', '5.7.1'

  ss.source_files = 'MintegralCustomEvent/MTGCommon/*.{h,m}','MintegralCustomEvent/MTGNativeAd/*.{h,m}'
  
end

spec.subspec 'InterstitialVideoAdAdapter' do |ss|

  ss.dependency 'Google-Mobile-Ads-SDK', '~> 7.27.0'
  ss.dependency 'MintegralAdSDK/InterstitialVideoAd', '5.7.1'
  ss.source_files = 'MintegralCustomEvent/MTGCommon/*.{h,m}','MintegralCustomEvent/MTGInterstitialVideoAd/*.{h,m}'
end


spec.subspec 'RewardVideoAdAdapter' do |ss|

  ss.dependency 'Google-Mobile-Ads-SDK', '~> 7.27.0'
  ss.dependency 'MintegralAdSDK/RewardVideoAd', '5.7.1'
  ss.source_files = 'MintegralCustomEvent/MTGCommon/*.{h,m}','MintegralCustomEvent/MTGRewardVideoAd/*.{h,m}'

end


spec.subspec 'InterstitialAdAdapter' do |ss|

  ss.dependency 'Google-Mobile-Ads-SDK', '~> 7.27.0'
  ss.dependency 'MintegralAdSDK/InterstitialAd','5.7.1'
  ss.source_files = 'MintegralCustomEvent/MTGCommon/*.{h,m}','MintegralCustomEvent/MTGInterstitialAd/*.{h,m}'
end


spec.subspec 'BannerAdAdapter' do |ss|

  ss.dependency 'Google-Mobile-Ads-SDK', '~> 7.27.0'
  ss.dependency 'MintegralAdSDK/BannerAd', '5.7.1'
  ss.source_files = 'MintegralCustomEvent/MTGCommon/*.{h,m}','MintegralCustomEvent/MTGBannerAd/*.{h,m}'
end



 
end
