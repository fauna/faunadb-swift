import UIKit
import FaunaDB

class EditPostController: UIViewController {

    @IBOutlet weak var pageTitle: UINavigationItem!
    @IBOutlet weak var postTitle: UITextField!
    @IBOutlet weak var postText: UITextView!

    var post: Post?
    var isEditingPost = false

    override func viewDidLoad() {
        isEditingPost = post != nil
        updateView()
    }

    private func updateView() {
        if isEditingPost {
            pageTitle.title = "Edit Post"
        }

        if let post = post {
            postTitle.text = post.title
            postText.text = post.text
        }
    }

    @IBAction func savePost(_ sender: Any) {
        let postToSave = Post(
            ref: post?.ref,
            title: postTitle.text?.trim() ?? "<No title>",
            text: postText.text.trim()
        )

        Post.save(postToSave).map(at: .main) { [weak self] savedPost in
            self?.post = savedPost
            self?.goBackToPreviousView()
        }
    }

    private func goBackToPreviousView() {
        if isEditingPost {
            self.performSegue(withIdentifier: "postUpdated", sender: self)
            return
        }

        self.performSegue(withIdentifier: "postAdded", sender: self)
    }
}
