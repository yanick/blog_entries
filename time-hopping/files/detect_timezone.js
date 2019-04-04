<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>
  pellepim / jsTimezoneDetect 
  / source  / detect_timezone.js
 &mdash; Bitbucket
</title>
  <link rel="icon" type="image/png" href="https://dwz7u9t8u8usb.cloudfront.net/m/e0d251052a46/img/favicon.png">
  <meta id="bb-canon-url" name="bb-canon-url" content="https://bitbucket.org">
  
  
<link rel="stylesheet" href="https://dwz7u9t8u8usb.cloudfront.net/m/e0d251052a46/compressed/css/d86ba1467b5c.css" type="text/css" />

  <!--[if IE]><link rel="stylesheet" href="https://dwz7u9t8u8usb.cloudfront.net/m/e0d251052a46/css/aui/aui-ie.css" media="all"><![endif]-->
  <!--[if IE 9]><link rel="stylesheet" href="https://dwz7u9t8u8usb.cloudfront.net/m/e0d251052a46/css/aui/aui-ie9.css" media="all"><![endif]-->
  <!--[if IE]><link rel="stylesheet" href="https://dwz7u9t8u8usb.cloudfront.net/m/e0d251052a46/css/aui-overrides-ie.css" media="all"><![endif]-->
  <meta name="description" content="
  
    Makes a robust determination of a user&#39;s timezone through Javascript.
  
"/>
  <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="Bitbucket" />
  
  <link href="/pellepim/jstimezonedetect/rss" rel="alternate nofollow" type="application/rss+xml" title="RSS feed for jsTimezoneDetect" />

</head>
<body class="aui-layout production ">
<script type="text/javascript" src="https://dwz7u9t8u8usb.cloudfront.net/m/e0d251052a46/compressed/js/e98deabf8a2e.js"></script>
<div id="page">
  <div id="wrapper">
    
    <header id="header" role="banner">
      <nav class="aui-header aui-dropdown2-trigger-group" role="navigation">
        <div class="aui-header-inner">
          <div class="aui-header-primary">
            <h1 class="aui-header-logo aui-header-logo-bitbucket">
              <a href="/" class="aui-nav-imagelink">
                <span class="aui-header-logo-device">Bitbucket</span>
              </a>
            </h1>
            <script id="repo-dropdown-template" type="text/html">
  

[[#hasViewed]]
  <div class="aui-dropdown2-section">
    <strong class="viewed">Recently viewed</strong>
    <ul class="aui-list-truncate">
      [[#viewed]]
        <li class="[[#is_private]]private[[/is_private]][[^is_private]]public[[/is_private]] repository">
          <a href="[[url]]" title="[[owner]]/[[name]]" class=" aui-icon-container">
            <img class="repo-avatar size16" src="[[{avatar}]]" alt="[[owner]]/[[name]] avatar"/>
            [[owner]] / [[name]]
          </a>
        </li>
      [[/viewed]]
    </ul>
  </div>
[[/hasViewed]]
[[#hasUpdated]]
<div class="aui-dropdown2-section">
  <strong class="updated">Recently updated</strong>
  <ul class="aui-list-truncate">
    [[#updated]]
    <li class="[[#is_private]]private[[/is_private]][[^is_private]]public[[/is_private]] repository">
      <a href="[[url]]" title="[[owner]]/[[name]]" class=" aui-icon-container">
        <img class="repo-avatar size16" src="[[{avatar}]]" alt="[[owner]]/[[name]] avatar"/>
        [[owner]] / [[name]]
      </a>
    </li>
    [[/updated]]
  </ul>
</div>
[[/hasUpdated]]

</script>
            <ul role="menu" class="aui-nav">
              
                <li>
                  <a href="/plans">
                    Pricing &amp; Signup
                  </a>
                </li>
              
            </ul>
          </div>
          <div class="aui-header-secondary">
            <ul role="menu" class="aui-nav">
              <li>
                <form action="/repo/all" method="get" class="aui-quicksearch">
                  <label for="search-query" class="assistive">owner/repository</label>
                  <input  id="search-query" class="search" type="text" placeholder="owner/repository" name="name">
                </form>
              </li>
              <li>
                <a class="aui-dropdown2-trigger"aria-controls="header-help-dropdown" aria-owns="header-help-dropdown"
                   aria-haspopup="true" data-container="#header .aui-header-inner" href="#header-help-dropdown">
                  <span class="aui-icon aui-icon-small aui-iconfont-help">Help</span><span class="aui-icon-dropdown"></span>
                </a>
                <nav id="header-help-dropdown" class="aui-dropdown2 aui-style-default aui-dropdown2-in-header" aria-hidden="true">
                  <div class="aui-dropdown2-section">
                    <ul>
                      <li><a href="https://confluence.atlassian.com/display/BITBUCKET/bitbucket+Documentation+Home" target="_blank">Documentation</a></li>
                      <li><a href="https://confluence.atlassian.com/display/BITBUCKET/bitbucket+101" target="_blank">Bitbucket 101</a></li>
                      <li><a href="https://confluence.atlassian.com/display/BBKB/Bitbucket+Knowledge+Base+Home" target="_blank">Knowledge Base</a></li>
                    </ul>
                  </div>
                  <div class="aui-dropdown2-section">
                    <ul>
                      <li><a href="https://answers.atlassian.com/tags/bitbucket/" target="_blank">Bitbucket on Atlassian Answers</a></li>
                      <li><a href="/support">Support</a></li>
                    </ul>
                  </div>
                </nav>
              </li>
              
                <li id="user-options">
                  <a href="/account/signin/?next=/pellepim/jstimezonedetect/src/f83d5a26fa638f7cc528430005761febb20ae447/detect_timezone.js%3Fat%3Ddefault" class="aui-nav-link login-link">Log In</a>
                </li>
              
            </ul>
          </div>
        </div>
      </nav>
    </header>
      <header id="account-warning" role="banner"
              class="aui-message-banner warning ">
        <div class="center-content">
          <span class="aui-icon aui-icon-warning"></span>
          <span class="message">
            
          </span>
        </div>
      </header>
    
      <header id="aui-message-bar">
        
      </header>
    
    
  <header id="repo-header" class="subhead row">
    <div class="center-content">
      <div class="repo-summary">
        <a class="repo-avatar-link" href="/pellepim/jstimezonedetect">
          <span class="repo-avatar-container size64">
  <img alt="jsTimezoneDetect" src="https://dwz7u9t8u8usb.cloudfront.net/m/e0d251052a46/img/language-avatars/js_64.png"/>
</span>

          
        </a>
        <h1><a class="repo-link" href="/pellepim/jstimezonedetect">jsTimezoneDetect</a></h1>
        <ul class="repo-metadata clearfix">
          <li>
            <a class="user" href="/pellepim">
              <span class="icon user">User Icon</span>
              <span>pellepim</span>
            </a>
          </li>
          
          
          <li class="social">
            <a class="follow" id="repo-follow"
               rel="nofollow"
               href="/pellepim/jstimezonedetect/follow">
              <span class="icon follow">Follow Icon</span>
              <span class="text">Follow</span>
            </a>
          </li>
          
        </ul>
      </div>
      <div id="repo-toolbar" class="bb-toolbar">
        <div class="aui-buttons">
          <a id="repo-clone-button" class="aui-button aui-style" href="https://bitbucket.org/pellepim/jstimezonedetect">
            <span class="icon clone">Clone Icon</span>
            <span>Clone</span>
            <span class="aui-icon-dropdown"></span>
          </a>
          <a id="fork-button" class="aui-button aui-style"
             href="/pellepim/jstimezonedetect/fork">
            <span class="icon fork">Fork Icon</span>
            <span>Fork</span>
          </a>
        </div>
        <div class="aui-buttons">
          <a id="compare-button" class="aui-button aui-style"
             href="/pellepim/jstimezonedetect/compare">
            <span class="icon compare">Compare Icon</span>
            <span>Compare</span>
          </a>
          <a id="pull-request-button" class="aui-button aui-style"
             href="/pellepim/jstimezonedetect/pull-request/new">
            <span class="icon pull-request">Pull Request Icon</span>
            <span>Pull Request</span>
          </a>
        </div>
        

<div id="repo-clone-dialog" class="clone-dialog hidden">
  
<div class="clone-url">
  <div class="aui-buttons">
    <a href="https://bitbucket.org/pellepim/jstimezonedetect"
       class="aui-button aui-style aui-dropdown2-trigger" aria-haspopup="true"
       aria-owns="clone-url-dropdown-header">
      <span class="dropdown-text">HTTPS</span>
    </a>
    <div id="clone-url-dropdown-header" class="aui-dropdown2 aui-style-default">
      <ul class="aui-list-truncate">
        <li>
          <a href="https://bitbucket.org/pellepim/jstimezonedetect"
            
              data-command="hg clone https://bitbucket.org/pellepim/jstimezonedetect"
            
            class="item-link https">HTTPS
          </a>
        </li>
        <li>
          <a href="ssh://hg@bitbucket.org/pellepim/jstimezonedetect"
            
              data-command="hg clone ssh://hg@bitbucket.org/pellepim/jstimezonedetect"
            
            class="item-link ssh">SSH
          </a>
        </li>
      </ul>
    </div>
    <input type="text" readonly="readonly" value="hg clone https://bitbucket.org/pellepim/jstimezonedetect">
  </div>
  
  <p>Need help cloning? Visit
     <a href="https://confluence.atlassian.com/x/cgozDQ" target="_blank">Bitbucket 101</a>.</p>
  
</div>

  
  
  <div class="clone-in-sourcetree"
       data-https-url="https://bitbucket.org/pellepim/jstimezonedetect"
       data-ssh-url="ssh://hg@bitbucket.org/pellepim/jstimezonedetect">
    <p><button class="aui-button aui-style aui-button-primary">Clone in SourceTree</button></p>

    <p><a href="http://www.sourcetreeapp.com" target="_blank">SourceTree</a>
       is a free Mac client by Atlassian for Git, Mercurial and Subversion.</p>
  </div>
  
</div>

      </div>
    </div>
    <div class="clearfix"></div>
  </header>
  <nav id="repo-tabs" class="aui-navbar aui-navbar-roomy">
    <div class="aui-navbar-inner">
      <ul class="aui-nav aui-nav-horizontal">
        
          <li>
            <a href="/pellepim/jstimezonedetect/overview" id="repo-overview-link">Overview</a>
          </li>
        
        
          <li class="aui-nav-selected">
            <a href="/pellepim/jstimezonedetect/src" id="repo-source-link">Source</a>
          </li>
        
        
          <li>
            <a href="/pellepim/jstimezonedetect/changesets" id="repo-commits-link">
              Commits
            </a>
          </li>
        
        
          <li>
            <a href="/pellepim/jstimezonedetect/pull-requests" id="repo-pullrequests-link">
              Pull Requests
              
                
              
            </a>
          </li>
        
          <li id="issues-tab" class="
            
              
            
          ">
            <a href="/pellepim/jstimezonedetect/issues?status=new&amp;status=open" id="repo-issues-link">
              Issues
              
                
                  <span class="aui-badge">8</span>
                
              
            </a>
          </li>
          <li id="wiki-tab" class="
              
                
              
            ">
            <a href="/pellepim/jstimezonedetect/wiki" id="repo-wiki-link">Wiki</a>
          </li>
        
          <li>
          <a href="/pellepim/jstimezonedetect/downloads" id="repo-downloads-link">
            Downloads
            
              
                <span class="aui-badge" id="downloads-count">1</span>
              
            
          </a>
          </li>
        
        
      </ul>
    </div>
  </nav>

    <div id="content" role="main">
      
  <div id="repo-content">
    
  <div id="source-container">
    



<header id="source-path">
  
  <div class="labels labels-csv">
    
      <div class="aui-buttons">
        <button data-branches-tags-url="/api/1.0/repositories/pellepim/jstimezonedetect/branches-tags"
                class="aui-button aui-style branch-dialog-trigger" title="default">
          <dl>
            
                
                  <dt class="branch">Branch</dt>
                  <dd class="branch">default</dd>
                
            
          </dl>
          <span class="aui-icon-dropdown"></span>
        </button>
      </div>
    
  </div>
  
  
    <div class="view-switcher">
      <div class="aui-buttons">
        
          <a href="/pellepim/jstimezonedetect/src/f83d5a26fa63/detect_timezone.js?at=default"
             class="aui-button aui-style pjax-trigger active">
            Source
          </a>
          <a href="/pellepim/jstimezonedetect/diff/detect_timezone.js?diff2=f83d5a26fa63&at=default"
             class="aui-button aui-style pjax-trigger "
             title="Diff to previous change">
            Diff
          </a>
          <a href="/pellepim/jstimezonedetect/history-node/f83d5a26fa63/detect_timezone.js?at=default"
             class="aui-button aui-style pjax-trigger ">
            History
          </a>
        
      </div>
    </div>
  
  <h1>
    <a href="/pellepim/jstimezonedetect/src/f83d5a26fa63?at=default"
       class="pjax-trigger" title="[u&#39;detect_timezone.js&#39;]">jsTimezoneDetect</a> /
    
      
        
          <span>detect_timezone.js</span>
        
      
    
  </h1>
  
    
    
  
  <div class="clearfix"></div>
</header>


  
    <div id="source-view">
      <div class="toolbar">
        <div class="primary">
          <div class="aui-buttons">
            
              <button id="file-history-trigger" class="aui-button aui-style changeset-info"
                      data-changeset="f83d5a26fa638f7cc528430005761febb20ae447"
                      data-path="detect_timezone.js"
                      data-current="f83d5a26fa638f7cc528430005761febb20ae447">
                
                   

<img class="avatar avatar16" src="https://secure.gravatar.com/avatar/1d7e2193370ebcead2bd9c44ecae6696?d=https%3A%2F%2Fdwz7u9t8u8usb.cloudfront.net%2Fm%2Fe0d251052a46%2Fimg%2Fdefault_avatar%2F16%2Fuser_blue.png&amp;s=16" alt="Brian Donovan avatar" />
<span class="changeset-hash">f83d5a2</span>
<time datetime="2012-10-05T00:59:31+00:00" class="timestamp"></time>
<span class="aui-icon-dropdown"></span>

                
              </button>
            
          </div>
        </div>
          <div class="secondary">
            
              <div class="aui-buttons">
                <a href="/pellepim/jstimezonedetect/annotate/f83d5a26fa638f7cc528430005761febb20ae447/detect_timezone.js?at=default"
                   class="aui-button aui-style pjax-trigger">Blame</a>
              </div>
            
            <div class="aui-buttons">
              
              <a href="/pellepim/jstimezonedetect/changeset/f83d5a26fa638f7cc528430005761febb20ae447" class="aui-button aui-style"
                 title="View full commit f83d5a2">Full Commit</a>
              
                <a id="embed-link" href="/pellepim/jstimezonedetect/src/f83d5a26fa638f7cc528430005761febb20ae447/detect_timezone.js?embed=t"
                   class="aui-button aui-style">Embed</a>
              
              <a href="/pellepim/jstimezonedetect/raw/f83d5a26fa638f7cc528430005761febb20ae447/detect_timezone.js"
                 class="aui-button aui-style">Raw</a>
            </div>
          </div>
        <div class="clearfix"></div>
      </div>
    </div>

    
      
        
          <div class="file-source">
            <table class="highlighttable"><tr><td class="linenos"><div class="linenodiv"><pre><a href="#cl-1">  1</a>
<a href="#cl-2">  2</a>
<a href="#cl-3">  3</a>
<a href="#cl-4">  4</a>
<a href="#cl-5">  5</a>
<a href="#cl-6">  6</a>
<a href="#cl-7">  7</a>
<a href="#cl-8">  8</a>
<a href="#cl-9">  9</a>
<a href="#cl-10"> 10</a>
<a href="#cl-11"> 11</a>
<a href="#cl-12"> 12</a>
<a href="#cl-13"> 13</a>
<a href="#cl-14"> 14</a>
<a href="#cl-15"> 15</a>
<a href="#cl-16"> 16</a>
<a href="#cl-17"> 17</a>
<a href="#cl-18"> 18</a>
<a href="#cl-19"> 19</a>
<a href="#cl-20"> 20</a>
<a href="#cl-21"> 21</a>
<a href="#cl-22"> 22</a>
<a href="#cl-23"> 23</a>
<a href="#cl-24"> 24</a>
<a href="#cl-25"> 25</a>
<a href="#cl-26"> 26</a>
<a href="#cl-27"> 27</a>
<a href="#cl-28"> 28</a>
<a href="#cl-29"> 29</a>
<a href="#cl-30"> 30</a>
<a href="#cl-31"> 31</a>
<a href="#cl-32"> 32</a>
<a href="#cl-33"> 33</a>
<a href="#cl-34"> 34</a>
<a href="#cl-35"> 35</a>
<a href="#cl-36"> 36</a>
<a href="#cl-37"> 37</a>
<a href="#cl-38"> 38</a>
<a href="#cl-39"> 39</a>
<a href="#cl-40"> 40</a>
<a href="#cl-41"> 41</a>
<a href="#cl-42"> 42</a>
<a href="#cl-43"> 43</a>
<a href="#cl-44"> 44</a>
<a href="#cl-45"> 45</a>
<a href="#cl-46"> 46</a>
<a href="#cl-47"> 47</a>
<a href="#cl-48"> 48</a>
<a href="#cl-49"> 49</a>
<a href="#cl-50"> 50</a>
<a href="#cl-51"> 51</a>
<a href="#cl-52"> 52</a>
<a href="#cl-53"> 53</a>
<a href="#cl-54"> 54</a>
<a href="#cl-55"> 55</a>
<a href="#cl-56"> 56</a>
<a href="#cl-57"> 57</a>
<a href="#cl-58"> 58</a>
<a href="#cl-59"> 59</a>
<a href="#cl-60"> 60</a>
<a href="#cl-61"> 61</a>
<a href="#cl-62"> 62</a>
<a href="#cl-63"> 63</a>
<a href="#cl-64"> 64</a>
<a href="#cl-65"> 65</a>
<a href="#cl-66"> 66</a>
<a href="#cl-67"> 67</a>
<a href="#cl-68"> 68</a>
<a href="#cl-69"> 69</a>
<a href="#cl-70"> 70</a>
<a href="#cl-71"> 71</a>
<a href="#cl-72"> 72</a>
<a href="#cl-73"> 73</a>
<a href="#cl-74"> 74</a>
<a href="#cl-75"> 75</a>
<a href="#cl-76"> 76</a>
<a href="#cl-77"> 77</a>
<a href="#cl-78"> 78</a>
<a href="#cl-79"> 79</a>
<a href="#cl-80"> 80</a>
<a href="#cl-81"> 81</a>
<a href="#cl-82"> 82</a>
<a href="#cl-83"> 83</a>
<a href="#cl-84"> 84</a>
<a href="#cl-85"> 85</a>
<a href="#cl-86"> 86</a>
<a href="#cl-87"> 87</a>
<a href="#cl-88"> 88</a>
<a href="#cl-89"> 89</a>
<a href="#cl-90"> 90</a>
<a href="#cl-91"> 91</a>
<a href="#cl-92"> 92</a>
<a href="#cl-93"> 93</a>
<a href="#cl-94"> 94</a>
<a href="#cl-95"> 95</a>
<a href="#cl-96"> 96</a>
<a href="#cl-97"> 97</a>
<a href="#cl-98"> 98</a>
<a href="#cl-99"> 99</a>
<a href="#cl-100">100</a>
<a href="#cl-101">101</a>
<a href="#cl-102">102</a>
<a href="#cl-103">103</a>
<a href="#cl-104">104</a>
<a href="#cl-105">105</a>
<a href="#cl-106">106</a>
<a href="#cl-107">107</a>
<a href="#cl-108">108</a>
<a href="#cl-109">109</a>
<a href="#cl-110">110</a>
<a href="#cl-111">111</a>
<a href="#cl-112">112</a>
<a href="#cl-113">113</a>
<a href="#cl-114">114</a>
<a href="#cl-115">115</a>
<a href="#cl-116">116</a>
<a href="#cl-117">117</a>
<a href="#cl-118">118</a>
<a href="#cl-119">119</a>
<a href="#cl-120">120</a>
<a href="#cl-121">121</a>
<a href="#cl-122">122</a>
<a href="#cl-123">123</a>
<a href="#cl-124">124</a>
<a href="#cl-125">125</a>
<a href="#cl-126">126</a>
<a href="#cl-127">127</a>
<a href="#cl-128">128</a>
<a href="#cl-129">129</a>
<a href="#cl-130">130</a>
<a href="#cl-131">131</a>
<a href="#cl-132">132</a>
<a href="#cl-133">133</a>
<a href="#cl-134">134</a>
<a href="#cl-135">135</a>
<a href="#cl-136">136</a>
<a href="#cl-137">137</a>
<a href="#cl-138">138</a>
<a href="#cl-139">139</a>
<a href="#cl-140">140</a>
<a href="#cl-141">141</a>
<a href="#cl-142">142</a>
<a href="#cl-143">143</a>
<a href="#cl-144">144</a>
<a href="#cl-145">145</a>
<a href="#cl-146">146</a>
<a href="#cl-147">147</a>
<a href="#cl-148">148</a>
<a href="#cl-149">149</a>
<a href="#cl-150">150</a>
<a href="#cl-151">151</a>
<a href="#cl-152">152</a>
<a href="#cl-153">153</a>
<a href="#cl-154">154</a>
<a href="#cl-155">155</a>
<a href="#cl-156">156</a>
<a href="#cl-157">157</a>
<a href="#cl-158">158</a>
<a href="#cl-159">159</a>
<a href="#cl-160">160</a>
<a href="#cl-161">161</a>
<a href="#cl-162">162</a>
<a href="#cl-163">163</a>
<a href="#cl-164">164</a>
<a href="#cl-165">165</a>
<a href="#cl-166">166</a>
<a href="#cl-167">167</a>
<a href="#cl-168">168</a>
<a href="#cl-169">169</a>
<a href="#cl-170">170</a>
<a href="#cl-171">171</a>
<a href="#cl-172">172</a>
<a href="#cl-173">173</a>
<a href="#cl-174">174</a>
<a href="#cl-175">175</a>
<a href="#cl-176">176</a>
<a href="#cl-177">177</a>
<a href="#cl-178">178</a>
<a href="#cl-179">179</a>
<a href="#cl-180">180</a>
<a href="#cl-181">181</a>
<a href="#cl-182">182</a>
<a href="#cl-183">183</a>
<a href="#cl-184">184</a>
<a href="#cl-185">185</a>
<a href="#cl-186">186</a>
<a href="#cl-187">187</a>
<a href="#cl-188">188</a>
<a href="#cl-189">189</a>
<a href="#cl-190">190</a>
<a href="#cl-191">191</a>
<a href="#cl-192">192</a>
<a href="#cl-193">193</a>
<a href="#cl-194">194</a>
<a href="#cl-195">195</a>
<a href="#cl-196">196</a>
<a href="#cl-197">197</a>
<a href="#cl-198">198</a>
<a href="#cl-199">199</a>
<a href="#cl-200">200</a>
<a href="#cl-201">201</a>
<a href="#cl-202">202</a>
<a href="#cl-203">203</a>
<a href="#cl-204">204</a>
<a href="#cl-205">205</a>
<a href="#cl-206">206</a>
<a href="#cl-207">207</a>
<a href="#cl-208">208</a>
<a href="#cl-209">209</a>
<a href="#cl-210">210</a>
<a href="#cl-211">211</a>
<a href="#cl-212">212</a>
<a href="#cl-213">213</a>
<a href="#cl-214">214</a>
<a href="#cl-215">215</a>
<a href="#cl-216">216</a>
<a href="#cl-217">217</a>
<a href="#cl-218">218</a>
<a href="#cl-219">219</a>
<a href="#cl-220">220</a>
<a href="#cl-221">221</a>
<a href="#cl-222">222</a>
<a href="#cl-223">223</a>
<a href="#cl-224">224</a>
<a href="#cl-225">225</a>
<a href="#cl-226">226</a>
<a href="#cl-227">227</a>
<a href="#cl-228">228</a>
<a href="#cl-229">229</a>
<a href="#cl-230">230</a>
<a href="#cl-231">231</a>
<a href="#cl-232">232</a>
<a href="#cl-233">233</a>
<a href="#cl-234">234</a>
<a href="#cl-235">235</a>
<a href="#cl-236">236</a>
<a href="#cl-237">237</a>
<a href="#cl-238">238</a>
<a href="#cl-239">239</a>
<a href="#cl-240">240</a>
<a href="#cl-241">241</a>
<a href="#cl-242">242</a>
<a href="#cl-243">243</a>
<a href="#cl-244">244</a>
<a href="#cl-245">245</a>
<a href="#cl-246">246</a>
<a href="#cl-247">247</a>
<a href="#cl-248">248</a>
<a href="#cl-249">249</a>
<a href="#cl-250">250</a>
<a href="#cl-251">251</a>
<a href="#cl-252">252</a>
<a href="#cl-253">253</a>
<a href="#cl-254">254</a>
<a href="#cl-255">255</a>
<a href="#cl-256">256</a>
<a href="#cl-257">257</a>
<a href="#cl-258">258</a>
<a href="#cl-259">259</a>
<a href="#cl-260">260</a>
<a href="#cl-261">261</a>
<a href="#cl-262">262</a>
<a href="#cl-263">263</a>
<a href="#cl-264">264</a>
<a href="#cl-265">265</a>
<a href="#cl-266">266</a>
<a href="#cl-267">267</a>
<a href="#cl-268">268</a>
<a href="#cl-269">269</a>
<a href="#cl-270">270</a>
<a href="#cl-271">271</a>
<a href="#cl-272">272</a>
<a href="#cl-273">273</a>
<a href="#cl-274">274</a>
<a href="#cl-275">275</a>
<a href="#cl-276">276</a>
<a href="#cl-277">277</a>
<a href="#cl-278">278</a>
<a href="#cl-279">279</a>
<a href="#cl-280">280</a>
<a href="#cl-281">281</a>
<a href="#cl-282">282</a>
<a href="#cl-283">283</a>
<a href="#cl-284">284</a>
<a href="#cl-285">285</a>
<a href="#cl-286">286</a>
<a href="#cl-287">287</a>
<a href="#cl-288">288</a>
<a href="#cl-289">289</a>
<a href="#cl-290">290</a>
<a href="#cl-291">291</a>
<a href="#cl-292">292</a>
<a href="#cl-293">293</a>
<a href="#cl-294">294</a>
<a href="#cl-295">295</a>
<a href="#cl-296">296</a>
<a href="#cl-297">297</a>
<a href="#cl-298">298</a>
<a href="#cl-299">299</a>
<a href="#cl-300">300</a>
<a href="#cl-301">301</a>
<a href="#cl-302">302</a>
<a href="#cl-303">303</a>
<a href="#cl-304">304</a>
<a href="#cl-305">305</a>
<a href="#cl-306">306</a>
<a href="#cl-307">307</a>
<a href="#cl-308">308</a>
<a href="#cl-309">309</a>
<a href="#cl-310">310</a>
<a href="#cl-311">311</a></pre></div></td><td class="code"><div class="highlight"><pre><a name="cl-1"></a><span class="cm">/*jslint undef: true */</span>
<a name="cl-2"></a><span class="cm">/*global console*/</span>
<a name="cl-3"></a><span class="cm">/*global exports*/</span>
<a name="cl-4"></a><span class="cm">/*version 2012-05-10*/</span>
<a name="cl-5"></a>
<a name="cl-6"></a><span class="p">(</span><span class="kd">function</span><span class="p">(</span><span class="nx">root</span><span class="p">)</span> <span class="p">{</span>
<a name="cl-7"></a>  <span class="cm">/**</span>
<a name="cl-8"></a><span class="cm">   * Namespace to hold all the code for timezone detection.</span>
<a name="cl-9"></a><span class="cm">   */</span>
<a name="cl-10"></a>  <span class="kd">var</span> <span class="nx">jstz</span> <span class="o">=</span> <span class="p">(</span><span class="kd">function</span> <span class="p">()</span> <span class="p">{</span>
<a name="cl-11"></a>      <span class="s1">&#39;use strict&#39;</span><span class="p">;</span>
<a name="cl-12"></a>      <span class="kd">var</span> <span class="nx">HEMISPHERE_SOUTH</span> <span class="o">=</span> <span class="s1">&#39;s&#39;</span><span class="p">,</span>
<a name="cl-13"></a>
<a name="cl-14"></a>          <span class="cm">/**</span>
<a name="cl-15"></a><span class="cm">           * Gets the offset in minutes from UTC for a certain date.</span>
<a name="cl-16"></a><span class="cm">           * @param {Date} date</span>
<a name="cl-17"></a><span class="cm">           * @returns {Number}</span>
<a name="cl-18"></a><span class="cm">           */</span>
<a name="cl-19"></a>          <span class="nx">get_date_offset</span> <span class="o">=</span> <span class="kd">function</span> <span class="p">(</span><span class="nx">date</span><span class="p">)</span> <span class="p">{</span>
<a name="cl-20"></a>              <span class="kd">var</span> <span class="nx">offset</span> <span class="o">=</span> <span class="o">-</span><span class="nx">date</span><span class="p">.</span><span class="nx">getTimezoneOffset</span><span class="p">();</span>
<a name="cl-21"></a>              <span class="k">return</span> <span class="p">(</span><span class="nx">offset</span> <span class="o">!==</span> <span class="kc">null</span> <span class="o">?</span> <span class="nx">offset</span> <span class="o">:</span> <span class="mi">0</span><span class="p">);</span>
<a name="cl-22"></a>          <span class="p">},</span>
<a name="cl-23"></a>
<a name="cl-24"></a>          <span class="nx">get_january_offset</span> <span class="o">=</span> <span class="kd">function</span> <span class="p">()</span> <span class="p">{</span>
<a name="cl-25"></a>              <span class="k">return</span> <span class="nx">get_date_offset</span><span class="p">(</span><span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2010</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">1</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">));</span>
<a name="cl-26"></a>          <span class="p">},</span>
<a name="cl-27"></a>
<a name="cl-28"></a>          <span class="nx">get_june_offset</span> <span class="o">=</span> <span class="kd">function</span> <span class="p">()</span> <span class="p">{</span>
<a name="cl-29"></a>              <span class="k">return</span> <span class="nx">get_date_offset</span><span class="p">(</span><span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2010</span><span class="p">,</span> <span class="mi">5</span><span class="p">,</span> <span class="mi">1</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">));</span>
<a name="cl-30"></a>          <span class="p">},</span>
<a name="cl-31"></a>
<a name="cl-32"></a>          <span class="cm">/**</span>
<a name="cl-33"></a><span class="cm">           * Private method.</span>
<a name="cl-34"></a><span class="cm">           * Checks whether a given date is in daylight savings time.</span>
<a name="cl-35"></a><span class="cm">           * If the date supplied is after june, we assume that we&#39;re checking</span>
<a name="cl-36"></a><span class="cm">           * for southern hemisphere DST.</span>
<a name="cl-37"></a><span class="cm">           * @param {Date} date</span>
<a name="cl-38"></a><span class="cm">           * @returns {Boolean}</span>
<a name="cl-39"></a><span class="cm">           */</span>
<a name="cl-40"></a>          <span class="nx">date_is_dst</span> <span class="o">=</span> <span class="kd">function</span> <span class="p">(</span><span class="nx">date</span><span class="p">)</span> <span class="p">{</span>
<a name="cl-41"></a>              <span class="kd">var</span> <span class="nx">base_offset</span> <span class="o">=</span> <span class="p">((</span><span class="nx">date</span><span class="p">.</span><span class="nx">getMonth</span><span class="p">()</span> <span class="o">&gt;</span> <span class="mi">5</span> <span class="o">?</span> <span class="nx">get_june_offset</span><span class="p">()</span>
<a name="cl-42"></a>                                                  <span class="o">:</span> <span class="nx">get_january_offset</span><span class="p">())),</span>
<a name="cl-43"></a>                  <span class="nx">date_offset</span> <span class="o">=</span> <span class="nx">get_date_offset</span><span class="p">(</span><span class="nx">date</span><span class="p">);</span>
<a name="cl-44"></a>
<a name="cl-45"></a>              <span class="k">return</span> <span class="p">(</span><span class="nx">base_offset</span> <span class="o">-</span> <span class="nx">date_offset</span><span class="p">)</span> <span class="o">!==</span> <span class="mi">0</span><span class="p">;</span>
<a name="cl-46"></a>          <span class="p">},</span>
<a name="cl-47"></a>
<a name="cl-48"></a>          <span class="cm">/**</span>
<a name="cl-49"></a><span class="cm">           * This function does some basic calculations to create information about</span>
<a name="cl-50"></a><span class="cm">           * the user&#39;s timezone.</span>
<a name="cl-51"></a><span class="cm">           *</span>
<a name="cl-52"></a><span class="cm">           * Returns a key that can be used to do lookups in jstz.olson.timezones.</span>
<a name="cl-53"></a><span class="cm">           *</span>
<a name="cl-54"></a><span class="cm">           * @returns {String}</span>
<a name="cl-55"></a><span class="cm">           */</span>
<a name="cl-56"></a>
<a name="cl-57"></a>          <span class="nx">lookup_key</span> <span class="o">=</span> <span class="kd">function</span> <span class="p">()</span> <span class="p">{</span>
<a name="cl-58"></a>              <span class="kd">var</span> <span class="nx">january_offset</span> <span class="o">=</span> <span class="nx">get_january_offset</span><span class="p">(),</span>
<a name="cl-59"></a>                  <span class="nx">june_offset</span> <span class="o">=</span> <span class="nx">get_june_offset</span><span class="p">(),</span>
<a name="cl-60"></a>                  <span class="nx">diff</span> <span class="o">=</span> <span class="nx">get_january_offset</span><span class="p">()</span> <span class="o">-</span> <span class="nx">get_june_offset</span><span class="p">();</span>
<a name="cl-61"></a>
<a name="cl-62"></a>              <span class="k">if</span> <span class="p">(</span><span class="nx">diff</span> <span class="o">&lt;</span> <span class="mi">0</span><span class="p">)</span> <span class="p">{</span>
<a name="cl-63"></a>                  <span class="k">return</span> <span class="nx">january_offset</span> <span class="o">+</span> <span class="s2">&quot;,1&quot;</span><span class="p">;</span>
<a name="cl-64"></a>              <span class="p">}</span> <span class="k">else</span> <span class="k">if</span> <span class="p">(</span><span class="nx">diff</span> <span class="o">&gt;</span> <span class="mi">0</span><span class="p">)</span> <span class="p">{</span>
<a name="cl-65"></a>                  <span class="k">return</span> <span class="nx">june_offset</span> <span class="o">+</span> <span class="s2">&quot;,1,&quot;</span> <span class="o">+</span> <span class="nx">HEMISPHERE_SOUTH</span><span class="p">;</span>
<a name="cl-66"></a>              <span class="p">}</span>
<a name="cl-67"></a>
<a name="cl-68"></a>              <span class="k">return</span> <span class="nx">january_offset</span> <span class="o">+</span> <span class="s2">&quot;,0&quot;</span><span class="p">;</span>
<a name="cl-69"></a>          <span class="p">},</span>
<a name="cl-70"></a>
<a name="cl-71"></a>          <span class="cm">/**</span>
<a name="cl-72"></a><span class="cm">           * Uses get_timezone_info() to formulate a key to use in the olson.timezones dictionary.</span>
<a name="cl-73"></a><span class="cm">           *</span>
<a name="cl-74"></a><span class="cm">           * Returns a primitive object on the format:</span>
<a name="cl-75"></a><span class="cm">           * {&#39;timezone&#39;: TimeZone, &#39;key&#39; : &#39;the key used to find the TimeZone object&#39;}</span>
<a name="cl-76"></a><span class="cm">           *</span>
<a name="cl-77"></a><span class="cm">           * @returns Object</span>
<a name="cl-78"></a><span class="cm">           */</span>
<a name="cl-79"></a>          <span class="nx">determine</span> <span class="o">=</span> <span class="kd">function</span> <span class="p">()</span> <span class="p">{</span>
<a name="cl-80"></a>              <span class="kd">var</span> <span class="nx">key</span> <span class="o">=</span> <span class="nx">lookup_key</span><span class="p">();</span>
<a name="cl-81"></a>              <span class="k">return</span> <span class="k">new</span> <span class="nx">jstz</span><span class="p">.</span><span class="nx">TimeZone</span><span class="p">(</span><span class="nx">jstz</span><span class="p">.</span><span class="nx">olson</span><span class="p">.</span><span class="nx">timezones</span><span class="p">[</span><span class="nx">key</span><span class="p">]);</span>
<a name="cl-82"></a>          <span class="p">};</span>
<a name="cl-83"></a>
<a name="cl-84"></a>      <span class="k">return</span> <span class="p">{</span>
<a name="cl-85"></a>          <span class="nx">determine_timezone</span> <span class="o">:</span> <span class="kd">function</span> <span class="p">()</span> <span class="p">{</span>
<a name="cl-86"></a>              <span class="k">if</span> <span class="p">(</span><span class="k">typeof</span> <span class="nx">console</span> <span class="o">!==</span> <span class="s1">&#39;undefined&#39;</span><span class="p">)</span> <span class="p">{</span>
<a name="cl-87"></a>                  <span class="nx">console</span><span class="p">.</span><span class="nx">log</span><span class="p">(</span><span class="s2">&quot;jstz.determine_timezone() is deprecated and will be removed in an upcoming version. Please use jstz.determine() instead.&quot;</span><span class="p">);</span>
<a name="cl-88"></a>              <span class="p">}</span>
<a name="cl-89"></a>              <span class="k">return</span> <span class="nx">determine</span><span class="p">();</span>
<a name="cl-90"></a>          <span class="p">},</span>
<a name="cl-91"></a>          <span class="nx">determine</span><span class="o">:</span> <span class="nx">determine</span><span class="p">,</span>
<a name="cl-92"></a>          <span class="nx">date_is_dst</span> <span class="o">:</span> <span class="nx">date_is_dst</span>
<a name="cl-93"></a>      <span class="p">};</span>
<a name="cl-94"></a>  <span class="p">}());</span>
<a name="cl-95"></a>
<a name="cl-96"></a>  <span class="cm">/**</span>
<a name="cl-97"></a><span class="cm">   * Simple object to perform ambiguity check and to return name of time zone.</span>
<a name="cl-98"></a><span class="cm">   */</span>
<a name="cl-99"></a>  <span class="nx">jstz</span><span class="p">.</span><span class="nx">TimeZone</span> <span class="o">=</span> <span class="kd">function</span> <span class="p">(</span><span class="nx">tz_name</span><span class="p">)</span> <span class="p">{</span>
<a name="cl-100"></a>      <span class="s1">&#39;use strict&#39;</span><span class="p">;</span>
<a name="cl-101"></a>      <span class="kd">var</span> <span class="nx">timezone_name</span> <span class="o">=</span> <span class="kc">null</span><span class="p">,</span>
<a name="cl-102"></a>
<a name="cl-103"></a>          <span class="nx">name</span> <span class="o">=</span> <span class="kd">function</span> <span class="p">()</span> <span class="p">{</span>
<a name="cl-104"></a>              <span class="k">return</span> <span class="nx">timezone_name</span><span class="p">;</span>
<a name="cl-105"></a>          <span class="p">},</span>
<a name="cl-106"></a>
<a name="cl-107"></a>          <span class="cm">/**</span>
<a name="cl-108"></a><span class="cm">           * Checks if a timezone has possible ambiguities. I.e timezones that are similar.</span>
<a name="cl-109"></a><span class="cm">           *</span>
<a name="cl-110"></a><span class="cm">           * For example, if the preliminary scan determines that we&#39;re in America/Denver.</span>
<a name="cl-111"></a><span class="cm">           * We double check here that we&#39;re really there and not in America/Mazatlan.</span>
<a name="cl-112"></a><span class="cm">           *</span>
<a name="cl-113"></a><span class="cm">           * This is done by checking known dates for when daylight savings start for different</span>
<a name="cl-114"></a><span class="cm">           * timezones during 2010 and 2011.</span>
<a name="cl-115"></a><span class="cm">           */</span>
<a name="cl-116"></a>          <span class="nx">ambiguity_check</span> <span class="o">=</span> <span class="kd">function</span> <span class="p">()</span> <span class="p">{</span>
<a name="cl-117"></a>              <span class="kd">var</span> <span class="nx">ambiguity_list</span> <span class="o">=</span> <span class="nx">jstz</span><span class="p">.</span><span class="nx">olson</span><span class="p">.</span><span class="nx">ambiguity_list</span><span class="p">[</span><span class="nx">timezone_name</span><span class="p">],</span>
<a name="cl-118"></a>                  <span class="nx">length</span> <span class="o">=</span> <span class="nx">ambiguity_list</span><span class="p">.</span><span class="nx">length</span><span class="p">,</span>
<a name="cl-119"></a>                  <span class="nx">i</span> <span class="o">=</span> <span class="mi">0</span><span class="p">,</span>
<a name="cl-120"></a>                  <span class="nx">tz</span> <span class="o">=</span> <span class="nx">ambiguity_list</span><span class="p">[</span><span class="mi">0</span><span class="p">];</span>
<a name="cl-121"></a>
<a name="cl-122"></a>              <span class="k">for</span> <span class="p">(;</span> <span class="nx">i</span> <span class="o">&lt;</span> <span class="nx">length</span><span class="p">;</span> <span class="nx">i</span> <span class="o">+=</span> <span class="mi">1</span><span class="p">)</span> <span class="p">{</span>
<a name="cl-123"></a>                  <span class="nx">tz</span> <span class="o">=</span> <span class="nx">ambiguity_list</span><span class="p">[</span><span class="nx">i</span><span class="p">];</span>
<a name="cl-124"></a>
<a name="cl-125"></a>                  <span class="k">if</span> <span class="p">(</span><span class="nx">jstz</span><span class="p">.</span><span class="nx">date_is_dst</span><span class="p">(</span><span class="nx">jstz</span><span class="p">.</span><span class="nx">olson</span><span class="p">.</span><span class="nx">dst_start_dates</span><span class="p">[</span><span class="nx">tz</span><span class="p">]))</span> <span class="p">{</span>
<a name="cl-126"></a>                      <span class="nx">timezone_name</span> <span class="o">=</span> <span class="nx">tz</span><span class="p">;</span>
<a name="cl-127"></a>                      <span class="k">return</span><span class="p">;</span>
<a name="cl-128"></a>                  <span class="p">}</span>
<a name="cl-129"></a>              <span class="p">}</span>
<a name="cl-130"></a>          <span class="p">},</span>
<a name="cl-131"></a>
<a name="cl-132"></a>          <span class="cm">/**</span>
<a name="cl-133"></a><span class="cm">           * Checks if it is possible that the timezone is ambiguous.</span>
<a name="cl-134"></a><span class="cm">           */</span>
<a name="cl-135"></a>          <span class="nx">is_ambiguous</span> <span class="o">=</span> <span class="kd">function</span> <span class="p">()</span> <span class="p">{</span>
<a name="cl-136"></a>              <span class="k">return</span> <span class="k">typeof</span> <span class="p">(</span><span class="nx">jstz</span><span class="p">.</span><span class="nx">olson</span><span class="p">.</span><span class="nx">ambiguity_list</span><span class="p">[</span><span class="nx">timezone_name</span><span class="p">])</span> <span class="o">!==</span> <span class="s1">&#39;undefined&#39;</span><span class="p">;</span>
<a name="cl-137"></a>          <span class="p">};</span>
<a name="cl-138"></a>
<a name="cl-139"></a>
<a name="cl-140"></a>
<a name="cl-141"></a>      <span class="nx">timezone_name</span> <span class="o">=</span> <span class="nx">tz_name</span><span class="p">;</span>
<a name="cl-142"></a>      <span class="k">if</span> <span class="p">(</span><span class="nx">is_ambiguous</span><span class="p">())</span> <span class="p">{</span>
<a name="cl-143"></a>          <span class="nx">ambiguity_check</span><span class="p">();</span>
<a name="cl-144"></a>      <span class="p">}</span>
<a name="cl-145"></a>
<a name="cl-146"></a>      <span class="k">return</span> <span class="p">{</span>
<a name="cl-147"></a>          <span class="nx">name</span><span class="o">:</span> <span class="nx">name</span>
<a name="cl-148"></a>      <span class="p">};</span>
<a name="cl-149"></a>  <span class="p">};</span>
<a name="cl-150"></a>
<a name="cl-151"></a>  <span class="nx">jstz</span><span class="p">.</span><span class="nx">olson</span> <span class="o">=</span> <span class="p">{};</span>
<a name="cl-152"></a>
<a name="cl-153"></a>  <span class="cm">/*</span>
<a name="cl-154"></a><span class="cm">   * The keys in this dictionary are comma separated as such:</span>
<a name="cl-155"></a><span class="cm">   *</span>
<a name="cl-156"></a><span class="cm">   * First the offset compared to UTC time in minutes.</span>
<a name="cl-157"></a><span class="cm">   *</span>
<a name="cl-158"></a><span class="cm">   * Then a flag which is 0 if the timezone does not take daylight savings into account and 1 if it</span>
<a name="cl-159"></a><span class="cm">   * does.</span>
<a name="cl-160"></a><span class="cm">   *</span>
<a name="cl-161"></a><span class="cm">   * Thirdly an optional &#39;s&#39; signifies that the timezone is in the southern hemisphere,</span>
<a name="cl-162"></a><span class="cm">   * only interesting for timezones with DST.</span>
<a name="cl-163"></a><span class="cm">   *</span>
<a name="cl-164"></a><span class="cm">   * The mapped arrays is used for constructing the jstz.TimeZone object from within</span>
<a name="cl-165"></a><span class="cm">   * jstz.determine_timezone();</span>
<a name="cl-166"></a><span class="cm">   */</span>
<a name="cl-167"></a>  <span class="nx">jstz</span><span class="p">.</span><span class="nx">olson</span><span class="p">.</span><span class="nx">timezones</span> <span class="o">=</span> <span class="p">{</span>
<a name="cl-168"></a>      <span class="s1">&#39;-720,0&#39;</span>   <span class="o">:</span> <span class="s1">&#39;Etc/GMT+12&#39;</span><span class="p">,</span>
<a name="cl-169"></a>      <span class="s1">&#39;-660,0&#39;</span>   <span class="o">:</span> <span class="s1">&#39;Pacific/Pago_Pago&#39;</span><span class="p">,</span>
<a name="cl-170"></a>      <span class="s1">&#39;-600,1&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Adak&#39;</span><span class="p">,</span>
<a name="cl-171"></a>      <span class="s1">&#39;-600,0&#39;</span>   <span class="o">:</span> <span class="s1">&#39;Pacific/Honolulu&#39;</span><span class="p">,</span>
<a name="cl-172"></a>      <span class="s1">&#39;-570,0&#39;</span>   <span class="o">:</span> <span class="s1">&#39;Pacific/Marquesas&#39;</span><span class="p">,</span>
<a name="cl-173"></a>      <span class="s1">&#39;-540,0&#39;</span>   <span class="o">:</span> <span class="s1">&#39;Pacific/Gambier&#39;</span><span class="p">,</span>
<a name="cl-174"></a>      <span class="s1">&#39;-540,1&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Anchorage&#39;</span><span class="p">,</span>
<a name="cl-175"></a>      <span class="s1">&#39;-480,1&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Los_Angeles&#39;</span><span class="p">,</span>
<a name="cl-176"></a>      <span class="s1">&#39;-480,0&#39;</span>   <span class="o">:</span> <span class="s1">&#39;Pacific/Pitcairn&#39;</span><span class="p">,</span>
<a name="cl-177"></a>      <span class="s1">&#39;-420,0&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Phoenix&#39;</span><span class="p">,</span>
<a name="cl-178"></a>      <span class="s1">&#39;-420,1&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Denver&#39;</span><span class="p">,</span>
<a name="cl-179"></a>      <span class="s1">&#39;-360,0&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Guatemala&#39;</span><span class="p">,</span>
<a name="cl-180"></a>      <span class="s1">&#39;-360,1&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Chicago&#39;</span><span class="p">,</span>
<a name="cl-181"></a>      <span class="s1">&#39;-360,1,s&#39;</span> <span class="o">:</span> <span class="s1">&#39;Pacific/Easter&#39;</span><span class="p">,</span>
<a name="cl-182"></a>      <span class="s1">&#39;-300,0&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Bogota&#39;</span><span class="p">,</span>
<a name="cl-183"></a>      <span class="s1">&#39;-300,1&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/New_York&#39;</span><span class="p">,</span>
<a name="cl-184"></a>      <span class="s1">&#39;-270,0&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Caracas&#39;</span><span class="p">,</span>
<a name="cl-185"></a>      <span class="s1">&#39;-240,1&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Halifax&#39;</span><span class="p">,</span>
<a name="cl-186"></a>      <span class="s1">&#39;-240,0&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Santo_Domingo&#39;</span><span class="p">,</span>
<a name="cl-187"></a>      <span class="s1">&#39;-240,1,s&#39;</span> <span class="o">:</span> <span class="s1">&#39;America/Asuncion&#39;</span><span class="p">,</span>
<a name="cl-188"></a>      <span class="s1">&#39;-210,1&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/St_Johns&#39;</span><span class="p">,</span>
<a name="cl-189"></a>      <span class="s1">&#39;-180,1&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Godthab&#39;</span><span class="p">,</span>
<a name="cl-190"></a>      <span class="s1">&#39;-180,0&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Argentina/Buenos_Aires&#39;</span><span class="p">,</span>
<a name="cl-191"></a>      <span class="s1">&#39;-180,1,s&#39;</span> <span class="o">:</span> <span class="s1">&#39;America/Montevideo&#39;</span><span class="p">,</span>
<a name="cl-192"></a>      <span class="s1">&#39;-120,0&#39;</span>   <span class="o">:</span> <span class="s1">&#39;America/Noronha&#39;</span><span class="p">,</span>
<a name="cl-193"></a>      <span class="s1">&#39;-120,1&#39;</span>   <span class="o">:</span> <span class="s1">&#39;Etc/GMT+2&#39;</span><span class="p">,</span>
<a name="cl-194"></a>      <span class="s1">&#39;-60,1&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Atlantic/Azores&#39;</span><span class="p">,</span>
<a name="cl-195"></a>      <span class="s1">&#39;-60,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Atlantic/Cape_Verde&#39;</span><span class="p">,</span>
<a name="cl-196"></a>      <span class="s1">&#39;0,0&#39;</span>      <span class="o">:</span> <span class="s1">&#39;Etc/UTC&#39;</span><span class="p">,</span>
<a name="cl-197"></a>      <span class="s1">&#39;0,1&#39;</span>      <span class="o">:</span> <span class="s1">&#39;Europe/London&#39;</span><span class="p">,</span>
<a name="cl-198"></a>      <span class="s1">&#39;60,1&#39;</span>     <span class="o">:</span> <span class="s1">&#39;Europe/Berlin&#39;</span><span class="p">,</span>
<a name="cl-199"></a>      <span class="s1">&#39;60,0&#39;</span>     <span class="o">:</span> <span class="s1">&#39;Africa/Lagos&#39;</span><span class="p">,</span>
<a name="cl-200"></a>      <span class="s1">&#39;60,1,s&#39;</span>   <span class="o">:</span> <span class="s1">&#39;Africa/Windhoek&#39;</span><span class="p">,</span>
<a name="cl-201"></a>      <span class="s1">&#39;120,1&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Beirut&#39;</span><span class="p">,</span>
<a name="cl-202"></a>      <span class="s1">&#39;120,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Africa/Johannesburg&#39;</span><span class="p">,</span>
<a name="cl-203"></a>      <span class="s1">&#39;180,1&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Europe/Moscow&#39;</span><span class="p">,</span>
<a name="cl-204"></a>      <span class="s1">&#39;180,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Baghdad&#39;</span><span class="p">,</span>
<a name="cl-205"></a>      <span class="s1">&#39;210,1&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Tehran&#39;</span><span class="p">,</span>
<a name="cl-206"></a>      <span class="s1">&#39;240,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Dubai&#39;</span><span class="p">,</span>
<a name="cl-207"></a>      <span class="s1">&#39;240,1&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Yerevan&#39;</span><span class="p">,</span>
<a name="cl-208"></a>      <span class="s1">&#39;270,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Kabul&#39;</span><span class="p">,</span>
<a name="cl-209"></a>      <span class="s1">&#39;300,1&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Yekaterinburg&#39;</span><span class="p">,</span>
<a name="cl-210"></a>      <span class="s1">&#39;300,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Karachi&#39;</span><span class="p">,</span>
<a name="cl-211"></a>      <span class="s1">&#39;330,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Kolkata&#39;</span><span class="p">,</span>
<a name="cl-212"></a>      <span class="s1">&#39;345,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Kathmandu&#39;</span><span class="p">,</span>
<a name="cl-213"></a>      <span class="s1">&#39;360,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Dhaka&#39;</span><span class="p">,</span>
<a name="cl-214"></a>      <span class="s1">&#39;360,1&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Omsk&#39;</span><span class="p">,</span>
<a name="cl-215"></a>      <span class="s1">&#39;390,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Rangoon&#39;</span><span class="p">,</span>
<a name="cl-216"></a>      <span class="s1">&#39;420,1&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Krasnoyarsk&#39;</span><span class="p">,</span>
<a name="cl-217"></a>      <span class="s1">&#39;420,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Jakarta&#39;</span><span class="p">,</span>
<a name="cl-218"></a>      <span class="s1">&#39;480,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Shanghai&#39;</span><span class="p">,</span>
<a name="cl-219"></a>      <span class="s1">&#39;480,1&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Irkutsk&#39;</span><span class="p">,</span>
<a name="cl-220"></a>      <span class="s1">&#39;525,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Australia/Eucla&#39;</span><span class="p">,</span>
<a name="cl-221"></a>      <span class="s1">&#39;525,1,s&#39;</span>  <span class="o">:</span> <span class="s1">&#39;Australia/Eucla&#39;</span><span class="p">,</span>
<a name="cl-222"></a>      <span class="s1">&#39;540,1&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Yakutsk&#39;</span><span class="p">,</span>
<a name="cl-223"></a>      <span class="s1">&#39;540,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Tokyo&#39;</span><span class="p">,</span>
<a name="cl-224"></a>      <span class="s1">&#39;570,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Australia/Darwin&#39;</span><span class="p">,</span>
<a name="cl-225"></a>      <span class="s1">&#39;570,1,s&#39;</span>  <span class="o">:</span> <span class="s1">&#39;Australia/Adelaide&#39;</span><span class="p">,</span>
<a name="cl-226"></a>      <span class="s1">&#39;600,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Australia/Brisbane&#39;</span><span class="p">,</span>
<a name="cl-227"></a>      <span class="s1">&#39;600,1&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Vladivostok&#39;</span><span class="p">,</span>
<a name="cl-228"></a>      <span class="s1">&#39;600,1,s&#39;</span>  <span class="o">:</span> <span class="s1">&#39;Australia/Sydney&#39;</span><span class="p">,</span>
<a name="cl-229"></a>      <span class="s1">&#39;630,1,s&#39;</span>  <span class="o">:</span> <span class="s1">&#39;Australia/Lord_Howe&#39;</span><span class="p">,</span>
<a name="cl-230"></a>      <span class="s1">&#39;660,1&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Asia/Kamchatka&#39;</span><span class="p">,</span>
<a name="cl-231"></a>      <span class="s1">&#39;660,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Pacific/Noumea&#39;</span><span class="p">,</span>
<a name="cl-232"></a>      <span class="s1">&#39;690,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Pacific/Norfolk&#39;</span><span class="p">,</span>
<a name="cl-233"></a>      <span class="s1">&#39;720,1,s&#39;</span>  <span class="o">:</span> <span class="s1">&#39;Pacific/Auckland&#39;</span><span class="p">,</span>
<a name="cl-234"></a>      <span class="s1">&#39;720,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Pacific/Tarawa&#39;</span><span class="p">,</span>
<a name="cl-235"></a>      <span class="s1">&#39;765,1,s&#39;</span>  <span class="o">:</span> <span class="s1">&#39;Pacific/Chatham&#39;</span><span class="p">,</span>
<a name="cl-236"></a>      <span class="s1">&#39;780,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Pacific/Tongatapu&#39;</span><span class="p">,</span>
<a name="cl-237"></a>      <span class="s1">&#39;780,1,s&#39;</span>  <span class="o">:</span> <span class="s1">&#39;Pacific/Apia&#39;</span><span class="p">,</span>
<a name="cl-238"></a>      <span class="s1">&#39;840,0&#39;</span>    <span class="o">:</span> <span class="s1">&#39;Pacific/Kiritimati&#39;</span>
<a name="cl-239"></a>  <span class="p">};</span>
<a name="cl-240"></a>
<a name="cl-241"></a>
<a name="cl-242"></a>  <span class="cm">/**</span>
<a name="cl-243"></a><span class="cm">   * This object contains information on when daylight savings starts for</span>
<a name="cl-244"></a><span class="cm">   * different timezones.</span>
<a name="cl-245"></a><span class="cm">   *</span>
<a name="cl-246"></a><span class="cm">   * The list is short for a reason. Often we do not have to be very specific</span>
<a name="cl-247"></a><span class="cm">   * to single out the correct timezone. But when we do, this list comes in</span>
<a name="cl-248"></a><span class="cm">   * handy.</span>
<a name="cl-249"></a><span class="cm">   *</span>
<a name="cl-250"></a><span class="cm">   * Each value is a date denoting when daylight savings starts for that timezone.</span>
<a name="cl-251"></a><span class="cm">   */</span>
<a name="cl-252"></a>  <span class="nx">jstz</span><span class="p">.</span><span class="nx">olson</span><span class="p">.</span><span class="nx">dst_start_dates</span> <span class="o">=</span> <span class="p">{</span>
<a name="cl-253"></a>      <span class="s1">&#39;America/Denver&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">13</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-254"></a>      <span class="s1">&#39;America/Mazatlan&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-255"></a>      <span class="s1">&#39;America/Chicago&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">13</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-256"></a>      <span class="s1">&#39;America/Mexico_City&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-257"></a>      <span class="s1">&#39;Atlantic/Stanley&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">8</span><span class="p">,</span> <span class="mi">4</span><span class="p">,</span> <span class="mi">7</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-258"></a>      <span class="s1">&#39;America/Asuncion&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">9</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-259"></a>      <span class="s1">&#39;America/Santiago&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">9</span><span class="p">,</span> <span class="mi">9</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-260"></a>      <span class="s1">&#39;America/Campo_Grande&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">9</span><span class="p">,</span> <span class="mi">16</span><span class="p">,</span> <span class="mi">5</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-261"></a>      <span class="s1">&#39;America/Montevideo&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">9</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-262"></a>      <span class="s1">&#39;America/Sao_Paulo&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">9</span><span class="p">,</span> <span class="mi">16</span><span class="p">,</span> <span class="mi">5</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-263"></a>      <span class="s1">&#39;America/Los_Angeles&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">13</span><span class="p">,</span> <span class="mi">8</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-264"></a>      <span class="s1">&#39;America/Santa_Isabel&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">5</span><span class="p">,</span> <span class="mi">8</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-265"></a>      <span class="s1">&#39;America/Havana&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">13</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-266"></a>      <span class="s1">&#39;America/New_York&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">13</span><span class="p">,</span> <span class="mi">7</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-267"></a>      <span class="s1">&#39;Asia/Gaza&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">26</span><span class="p">,</span> <span class="mi">23</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-268"></a>      <span class="s1">&#39;Asia/Beirut&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">27</span><span class="p">,</span> <span class="mi">1</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-269"></a>      <span class="s1">&#39;Europe/Minsk&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">27</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-270"></a>      <span class="s1">&#39;Europe/Helsinki&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">27</span><span class="p">,</span> <span class="mi">4</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-271"></a>      <span class="s1">&#39;Europe/Istanbul&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">28</span><span class="p">,</span> <span class="mi">5</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-272"></a>      <span class="s1">&#39;Asia/Damascus&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">1</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-273"></a>      <span class="s1">&#39;Asia/Jerusalem&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">1</span><span class="p">,</span> <span class="mi">6</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-274"></a>      <span class="s1">&#39;Africa/Cairo&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2010</span><span class="p">,</span> <span class="mi">3</span><span class="p">,</span> <span class="mi">30</span><span class="p">,</span> <span class="mi">4</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-275"></a>      <span class="s1">&#39;Asia/Yerevan&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">27</span><span class="p">,</span> <span class="mi">4</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-276"></a>      <span class="s1">&#39;Asia/Baku&#39;</span>    <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">27</span><span class="p">,</span> <span class="mi">8</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-277"></a>      <span class="s1">&#39;Pacific/Auckland&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">8</span><span class="p">,</span> <span class="mi">26</span><span class="p">,</span> <span class="mi">7</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-278"></a>      <span class="s1">&#39;Pacific/Fiji&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2010</span><span class="p">,</span> <span class="mi">11</span><span class="p">,</span> <span class="mi">29</span><span class="p">,</span> <span class="mi">23</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-279"></a>      <span class="s1">&#39;America/Halifax&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">13</span><span class="p">,</span> <span class="mi">6</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-280"></a>      <span class="s1">&#39;America/Goose_Bay&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">13</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">1</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-281"></a>      <span class="s1">&#39;America/Miquelon&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">13</span><span class="p">,</span> <span class="mi">5</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">),</span>
<a name="cl-282"></a>      <span class="s1">&#39;America/Godthab&#39;</span> <span class="o">:</span> <span class="k">new</span> <span class="nb">Date</span><span class="p">(</span><span class="mi">2011</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">27</span><span class="p">,</span> <span class="mi">1</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">)</span>
<a name="cl-283"></a>  <span class="p">};</span>
<a name="cl-284"></a>
<a name="cl-285"></a>  <span class="cm">/**</span>
<a name="cl-286"></a><span class="cm">   * The keys in this object are timezones that we know may be ambiguous after</span>
<a name="cl-287"></a><span class="cm">   * a preliminary scan through the olson_tz object.</span>
<a name="cl-288"></a><span class="cm">   *</span>
<a name="cl-289"></a><span class="cm">   * The array of timezones to compare must be in the order that daylight savings</span>
<a name="cl-290"></a><span class="cm">   * starts for the regions.</span>
<a name="cl-291"></a><span class="cm">   */</span>
<a name="cl-292"></a>  <span class="nx">jstz</span><span class="p">.</span><span class="nx">olson</span><span class="p">.</span><span class="nx">ambiguity_list</span> <span class="o">=</span> <span class="p">{</span>
<a name="cl-293"></a>      <span class="s1">&#39;America/Denver&#39;</span> <span class="o">:</span> <span class="p">[</span><span class="s1">&#39;America/Denver&#39;</span><span class="p">,</span> <span class="s1">&#39;America/Mazatlan&#39;</span><span class="p">],</span>
<a name="cl-294"></a>      <span class="s1">&#39;America/Chicago&#39;</span> <span class="o">:</span> <span class="p">[</span><span class="s1">&#39;America/Chicago&#39;</span><span class="p">,</span> <span class="s1">&#39;America/Mexico_City&#39;</span><span class="p">],</span>
<a name="cl-295"></a>      <span class="s1">&#39;America/Asuncion&#39;</span> <span class="o">:</span> <span class="p">[</span><span class="s1">&#39;Atlantic/Stanley&#39;</span><span class="p">,</span> <span class="s1">&#39;America/Asuncion&#39;</span><span class="p">,</span> <span class="s1">&#39;America/Santiago&#39;</span><span class="p">,</span> <span class="s1">&#39;America/Campo_Grande&#39;</span><span class="p">],</span>
<a name="cl-296"></a>      <span class="s1">&#39;America/Montevideo&#39;</span> <span class="o">:</span> <span class="p">[</span><span class="s1">&#39;America/Montevideo&#39;</span><span class="p">,</span> <span class="s1">&#39;America/Sao_Paulo&#39;</span><span class="p">],</span>
<a name="cl-297"></a>      <span class="s1">&#39;Asia/Beirut&#39;</span> <span class="o">:</span> <span class="p">[</span><span class="s1">&#39;Asia/Gaza&#39;</span><span class="p">,</span> <span class="s1">&#39;Asia/Beirut&#39;</span><span class="p">,</span> <span class="s1">&#39;Europe/Minsk&#39;</span><span class="p">,</span> <span class="s1">&#39;Europe/Helsinki&#39;</span><span class="p">,</span> <span class="s1">&#39;Europe/Istanbul&#39;</span><span class="p">,</span> <span class="s1">&#39;Asia/Damascus&#39;</span><span class="p">,</span> <span class="s1">&#39;Asia/Jerusalem&#39;</span><span class="p">,</span> <span class="s1">&#39;Africa/Cairo&#39;</span><span class="p">],</span>
<a name="cl-298"></a>      <span class="s1">&#39;Asia/Yerevan&#39;</span> <span class="o">:</span> <span class="p">[</span><span class="s1">&#39;Asia/Yerevan&#39;</span><span class="p">,</span> <span class="s1">&#39;Asia/Baku&#39;</span><span class="p">],</span>
<a name="cl-299"></a>      <span class="s1">&#39;Pacific/Auckland&#39;</span> <span class="o">:</span> <span class="p">[</span><span class="s1">&#39;Pacific/Auckland&#39;</span><span class="p">,</span> <span class="s1">&#39;Pacific/Fiji&#39;</span><span class="p">],</span>
<a name="cl-300"></a>      <span class="s1">&#39;America/Los_Angeles&#39;</span> <span class="o">:</span> <span class="p">[</span><span class="s1">&#39;America/Los_Angeles&#39;</span><span class="p">,</span> <span class="s1">&#39;America/Santa_Isabel&#39;</span><span class="p">],</span>
<a name="cl-301"></a>      <span class="s1">&#39;America/New_York&#39;</span> <span class="o">:</span> <span class="p">[</span><span class="s1">&#39;America/Havana&#39;</span><span class="p">,</span> <span class="s1">&#39;America/New_York&#39;</span><span class="p">],</span>
<a name="cl-302"></a>      <span class="s1">&#39;America/Halifax&#39;</span> <span class="o">:</span> <span class="p">[</span><span class="s1">&#39;America/Goose_Bay&#39;</span><span class="p">,</span> <span class="s1">&#39;America/Halifax&#39;</span><span class="p">],</span>
<a name="cl-303"></a>      <span class="s1">&#39;America/Godthab&#39;</span> <span class="o">:</span> <span class="p">[</span><span class="s1">&#39;America/Miquelon&#39;</span><span class="p">,</span> <span class="s1">&#39;America/Godthab&#39;</span><span class="p">]</span>
<a name="cl-304"></a>  <span class="p">};</span>
<a name="cl-305"></a>
<a name="cl-306"></a>  <span class="k">if</span> <span class="p">(</span><span class="k">typeof</span> <span class="nx">exports</span> <span class="o">!==</span> <span class="s1">&#39;undefined&#39;</span><span class="p">)</span> <span class="p">{</span>
<a name="cl-307"></a>    <span class="nx">exports</span><span class="p">.</span><span class="nx">jstz</span> <span class="o">=</span> <span class="nx">jstz</span><span class="p">;</span>
<a name="cl-308"></a>  <span class="p">}</span> <span class="k">else</span> <span class="p">{</span>
<a name="cl-309"></a>    <span class="nx">root</span><span class="p">.</span><span class="nx">jstz</span> <span class="o">=</span> <span class="nx">jstz</span><span class="p">;</span>
<a name="cl-310"></a>  <span class="p">}</span>
<a name="cl-311"></a><span class="p">})(</span><span class="k">this</span><span class="p">);</span>
</pre></div>
</td></tr></table>
          </div>
        
      
    
  


  <script id="source-changeset" type="text/html">
  

<a href="/pellepim/jstimezonedetect/src/[[raw_node]]/detect_timezone.js?at=default"
   class="[[#selected]]highlight[[/selected]]"
   data-hash="[[node]]">
  [[#author.username]]
    <img class="avatar avatar16" src="[[author.avatar]]"/>
    <span class="author" title="[[raw_author]]">[[author.display_name]]</span>
  [[/author.username]]
  [[^author.username]]
    <img class="avatar avatar16" src="https://dwz7u9t8u8usb.cloudfront.net/m/e0d251052a46/img/default_avatar/16/user_blue.png"/>
    <span class="author unmapped" title="[[raw_author]]">[[author]]</span>
  [[/author.username]]
  <time datetime="[[utctimestamp]]" data-title="true">[[utctimestamp]]</time>
  <span class="message">[[message]]</span>
</a>

</script>
  <script id="branch-dialog-template" type="text/html">
  

<div class="tabbed-filter-widget branch-dialog">
  <div class="tabbed-filter">
    <input placeholder="Filter Branches" class="filter-box" autosave="branch-dropdown-149161" type="text">
    <div class="aui-tabs horizontal-tabs aui-tabs-disabled filter-tabs">
      <ul class="tabs-menu">
        <li class="menu-item active-tab"><a href="#branches">Branches</a></li>
        <li class="menu-item"><a href="#tags">Tags</a></li>
      </ul>
    </div>
  </div>
  
    <div class="tab-pane active-pane" id="branches" data-filter-placeholder="Filter Branches">
      <ol class="filter-list">
        <li class="empty-msg">No matching branches</li>
        [[#branches]]
          [[#hasMultipleHeads]]
            [[#heads]]
              <li class="comprev filter-item">
                <a href="/pellepim/jstimezonedetect/src/[[changeset]]/detect_timezone.js?at=[[safeName]]" title="[[name]]">
                  [[name]] ([[shortChangeset]])
                </a>
              </li>
            [[/heads]]
          [[/hasMultipleHeads]]
          [[^hasMultipleHeads]]
            <li class="comprev filter-item">
              <a href="/pellepim/jstimezonedetect/src/[[changeset]]/detect_timezone.js?at=[[safeName]]" title="[[name]]">
                [[name]]
              </a>
            </li>
          [[/hasMultipleHeads]]
        [[/branches]]
      </ol>
    </div>
    <div class="tab-pane" id="tags" data-filter-placeholder="Filter Tags">
      <ol class="filter-list">
        <li class="empty-msg">No matching tags</li>
        [[#tags]]
          <li class="comprev filter-item">
            <a href="/pellepim/jstimezonedetect/src/[[changeset]]/detect_timezone.js?at=[[safeName]]" title="[[name]]">
              [[name]]
            </a>
          </li>
        [[/tags]]
      </ol>
    </div>
  
</div>

</script>


<div class="mask"></div>


  </div>

  </div>

    </div>
  </div>
  <footer id="footer" role="contentinfo">
    <section class="footer-body">
      <ul>
        <li><a href="http://blog.bitbucket.org">Blog</a></li>
        <li><a href="//bitbucket.org/site/master/issues/new">Report a Bug</a></li>
        <li><a href="/support">Support</a></li>
        <li><a href="http://confluence.atlassian.com/display/BITBUCKET">Documentation</a></li>
        <li><a href="http://confluence.atlassian.com/x/IYBGDQ">API</a></li>
        <li><a href="http://groups.google.com/group/bitbucket-users">Forum</a></li>
        <li><a href="http://status.bitbucket.org/">Server Status</a></li>
        <li><a href="http://www.atlassian.com/hosted/terms.jsp">Terms of Service</a></li>
        <li><a href="http://www.atlassian.com/about/privacy.jsp">Privacy Policy</a></li>
      </ul>
    </section>
  </footer>
</div>

<script type="text/javascript" src="https://dwz7u9t8u8usb.cloudfront.net/m/e0d251052a46/compressed/js/22e9495c4ecd.js"></script>

<!-- This script exists purely for the benefit of our selenium tests -->
<script>
  setTimeout(function () {
    BB.JsLoaded = true;
  }, 3000);
</script>



<script>
  (function (window) {
    BB.images = {
      invitation: 'https://dwz7u9t8u8usb.cloudfront.net/m/e0d251052a46/img/icons/fugue/card_address.png',
      noAvatar: 'https://dwz7u9t8u8usb.cloudfront.net/m/e0d251052a46/img/default_avatar/16/user_blue.png'
    };
    BB.user = {"isKbdShortcutsEnabled": true, "isSshEnabled": false, "isAuthenticated": false};
    BB.repo || (BB.repo = {});
    
      BB.repo.id = 149161;
      
      
        BB.repo.language = 'javascript';
        BB.repo.pygmentsLanguage = 'javascript';
      
      
        BB.repo.slug = 'jstimezonedetect';
      
      
        BB.repo.owner = {};
        BB.repo.owner.username = 'pellepim';
      
      // Coerce `BB.repo` to a string to get
      // "davidchambers/mango" or whatever.
      BB.repo.toString = function () {
        return BB.cname ? this.slug : '{owner.username}/{slug}'.format(this);
      }
      
        BB.changeset = 'f83d5a26fa638f7cc528430005761febb20ae447'
      
      
    
    window.setInterval(BB.localize, 60 * 1000);

  })(window);
</script>



<script>
    // Bitbucket Google Analytics
    (function (window) {
        // Track the main pageview to the Bitbucket GA account.
        BB.gaqPush(['_trackPageview']);
        // Track the main pageview to the Atlassian GA account.
        BB.gaqPush(['atl._trackPageview']);

        
            // Track the repository page view to the Repo Owner's GA account.
            BB.gaqPush(
                    ['repo._setAccount', 'UA-8177278-4'],
                    ['repo._trackPageview']
            );
        


        

        // Include GA commands from sub-templates
        

        (function () {
            var ga = document.createElement('script');
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            ga.setAttribute('async', 'true');
            document.documentElement.firstChild.appendChild(ga);
        }());
    })(window);
</script>




</body>
</html>
