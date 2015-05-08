    ______                                      _   _____ _                 _
    |  _  \                                    | | /  __ \ |               | |
    | | | |___   ___ _   _ _ __ ___   ___ _ __ | |_| /  \/ | ___  _   _  __| |
    | | | / _ \ / __| | | | '_ ` _ \ / _ \ '_ \| __| |   | |/ _ \| | | |/ _` |
    | |/ / (_) | (__| |_| | | | | | |  __/ | | | |_| \__/\ | (_) | |_| | (_| |
    |___/ \___/ \___|\__,_|_| |_| |_|\___|_| |_|\__|\____/_|\___/ \__,_|\__,_|


DocumentCloud is a catalog of primary source documents and a tool for annotating, organizing and publishing them on the web. Documents are contributed by journalists, researchers and archivists.

This codebase contains the entirety of DocumentCloud.org, and pulls together the rest of our open-source projects: Docsplit is used to extract data from incoming documents; that work is parallelized across CloudCrowd; data on the client-side is modeled by Backbone.js, which depends on Underscore.js for all of its abilities; Jammit concatenates and compresses the dozens of CSS and JS files into a single asset package; the NYTimes' Document Viewer displays the documents, while Pixel Ping records the traffic.

If you find a security issue while browsing the source, please email support@documentcloud.org to inform us of the problem.

Code contributed to this project is provided under the MIT license (see the LICENSE file). Some components of the project are subject to their own licenses as indicated (see /vendor and /public/javascripts/vendor directories).
