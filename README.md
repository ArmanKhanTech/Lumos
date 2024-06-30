[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<br />
<div align="center">
  <a href="https://github.com/ArmanKhanTech/Quill/">
    <img src="https://github.com/ArmanKhanTech/Quill/assets/92728787/c6501dd6-e82c-4f17-9156-42a7cea979cd" alt="Logo" width="80" height="80" >
  </a>

  <h3 align="center">Quill</h3>
  <p align="center">Status: Ongoing</p>

  <p align="center">
    A Flutter image editor package.
    <br />
    <br />
    <a href="https://github.com/ArmanKhanTech/Quill"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/ArmanKhanTech/Quill/issues">Report a Bug</a>
    ·
    <a href="https://github.com/ArmanKhanTech/Quill/issues">Request new Feature</a>
  </p>
</div>
<br />



<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About the Project</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#screenshots">Screenshots</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



## About the Project

Easily integrate powerful image editing capabilities into your Flutter applications with Quill. This package empowers developers to seamlessly incorporate features like crop, rotate, flip, filters, and more directly into their apps, providing users with robust tools to enhance and customize images on the fly. Whether you're building a photo-sharing app, an e-commerce platform, or a creative tool, the Flutter Image Editor offers a versatile solution with an intuitive interface and efficient performance. Take control of image manipulation in your Flutter projects and elevate user experience with this flexible and easy-to-use package.

<b>Key Features:<b>

<li>Crop, rotate, and flip images.</li>
<li>Apply filters and effects in real-time.</li>
<li>Adjust brightness, contrast, saturation, and more.</li>
<li>Add text & emojies to images.</li>
<li>Edit single & even multiple images.</li>
<li>Dark & Light mode.</li>
<li>Blur the images.</li>
<li>Undo and redo changes seamlessly.</li>
<br />

**Supports Android & iOS only.**



## Usage

### Single Image 
```js
Uint8List editedImage = SingleImageEditor(
          image: image,
          darkTheme: true,
          background: EditorBackground.blur,
          viewportSize: MediaQuery.of(context).size,
          features: const ImageEditorFeatures(
            crop: true,
            rotate: true,
            adjust: true,
            emoji: true,
            filters: true,
            flip: true,
            text: true,
            blur: true,
          ),
          cropAvailableRatios: const [
            AspectRatioOption(title: 'Freeform'),
            AspectRatioOption(title: '1:1', ratio: 1),
            AspectRatioOption(title: '4:3', ratio: 4 / 3),
            AspectRatioOption(title: '5:4', ratio: 5 / 4),
            AspectRatioOption(title: '7:5', ratio: 7 / 5),
            AspectRatioOption(title: '16:9', ratio: 16 / 9),
          ],
        ),
      ),
    );
```

### Multi Image
```js
List<Uint8List> editedImages = await Navigator.push(
      context!,
      CupertinoPageRoute(
        builder: (context) => MultiImageEditor(
          images: images,
          darkTheme: false,
          background: EditorBackground.none,
          viewportSize: MediaQuery.of(context).size,
          features: const ImageEditorFeatures(
            crop: true,
            rotate: true,
            adjust: true,
            emoji: true,
            filters: true,
            flip: true,
            text: true,
            blur: true,
          ),
          cropAvailableRatios: const [
            AspectRatioOption(title: 'Freeform'),
            AspectRatioOption(title: '1:1', ratio: 1),
            AspectRatioOption(title: '4:3', ratio: 4 / 3),
            AspectRatioOption(title: '5:4', ratio: 5 / 4),
            AspectRatioOption(title: '7:5', ratio: 7 / 5),
            AspectRatioOption(title: '16:9', ratio: 16 / 9),
          ],
        ),
      ),
    );
```

### Parameters

| Sr No. | Parameter          | Type                    | Description                                                                                                                                         | Required? |
|--------|--------------------|-------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| 1      | image              | dynamic                 | Referance to the image user wants to edit. Only for Single Image Editor.                                                                            | Yes       |
| 2      | images             | List&lt;dynamic&gt; | Referance to the images user wants to edit. Only for Multi Image Editor.                                                                            | Yes       |
| 3      | features           | ImageEditorFeatures     | The edit features you want the users to have access to. Valid features are: crop, adjust, blur, emoji, flip, rotate, text &amp; filters. All are allowed by default.   | No        |
| 4      | cropAvailableRatio | List&lt;AspectRatioOption&gt;   | List of crop ratios that will be available to the users. Vaild ratios are: freeform, 1:1, 4:3, 5:4, 7:5 &amp; 16:9. All ratios are available by default. | No        |
| 5      | viewportSize       | Size                    | Viewport size of the user's device to adjust &amp; fit image onto the edit screen.                                                                     | Yes       |
| 6      | darkTheme          | bool                    | The theme of the image editor. True for dark theme and false for light theme.                                                                       | Yes       |
| 7      | background         | enum EditorBackground   | Defines the background of the image editor. Valid constants are: none, blur &amp; gradient                                                                                                     | Yes       |


## Screenshots
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">
<img src="" alt="Logo" width="250" height="500">



## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

Don't forget to give the project a star! 

Thanks again!



## License

Distributed under the MIT License. See `LICENSE.txt` for more information.



## Contact

Arman Khan - ak2341776@gmail.com

Project Link - [https://github.com/ArmanKhanTech/Quill](https://github.com/ArmanKhanTech/Quill)



[contributors-shield]: https://img.shields.io/github/contributors/ArmanKhanTech/Quill.svg?style=for-the-badge
[contributors-url]: https://github.com/ArmanKhanTech/Quill/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/ArmanKhanTech/Quill.svg?style=for-the-badge
[forks-url]: https://github.com/ArmanKhanTech/Quill/network/members
[stars-shield]: https://img.shields.io/github/stars/ArmanKhanTech/Quill.svg?style=for-the-badge
[stars-url]: https://github.com/ArmanKhanTech/Quill/stargazers
[issues-shield]: https://img.shields.io/github/issues/ArmanKhanTech/Quill.svg?style=for-the-badge
[issues-url]: https://github.com/ArmanKhanTech/Quill/issues
[license-shield]: https://img.shields.io/github/license/ArmanKhanTech/Quill.svg?style=for-the-badge
[license-url]: https://github.com/ArmanKhanTech/Quill/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/arman-khan-25b624205/
[Android]: https://img.shields.io/badge/Android%20Studio-3DDC84.svg?style=for-the-badge&logo=android-studio&logoColor=white
[Android-url]: https://developer.android.com/
[Java]: https://img.shields.io/badge/java-%23ED8B00.svg?style=for-the-badge&logo=openjdk&logoColor=white
[Java-url]: https://www.java.com/
