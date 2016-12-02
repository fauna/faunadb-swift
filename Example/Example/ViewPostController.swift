import UIKit
import FaunaDB

class ViewPostController: UIViewController {

    @IBOutlet weak var postTitle: UINavigationItem!
    @IBOutlet weak var postBody: UITextView!
    @IBOutlet weak var editPost: UIBarButtonItem!

    var postUpdatedCallback: ((Post) -> Void)?
    var refAndTitle: Post.RefAndTitle?
    var post: Post?

    override func viewDidLoad() {
        guard let refAndTitle = refAndTitle else { return }
        postTitle.title = refAndTitle.title
        postBody.text = "Loading..."

        Post.load(byRef: refAndTitle.ref).map(at: .main) { [weak self] post in
            self?.post = post
            self?.updateView()
        }
    }

    private func updateView() {
        guard let post = post else { return }
        postTitle.title = post.title
        postBody.text = "\(post.title)\n\n\(post.text ?? "")"
    }

    @IBAction func deletePost(_ sender: Any) {
        let confirmation = UIAlertController(
            title: "Are you sure?",
            message: "Are you sure you want to delete this post?",
            preferredStyle: .alert
        )

        confirmation.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirmation.addAction(UIAlertAction(title: "Yes, delete it", style: .destructive, handler: deleteSelectedPost))
        present(confirmation, animated: true)
    }

    private func deleteSelectedPost(_ action: UIAlertAction) {
        guard let ref = post?.ref else { return }

        Post.delete(at: ref).map(at: .main) { [weak self] in
            self?.performSegue(withIdentifier: "postDeleted", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let editPost = segue.destination as? EditPostController,
            let postToEdit = post
            else { return }

        editPost.post = postToEdit
    }

    @IBAction func unwindToViewPost(sender: UIStoryboardSegue) {
        guard
            let editPost = sender.source as? EditPostController,
            let editedPost = editPost.post
            else { return }

        post = editedPost
        postUpdatedCallback?(editedPost)
        updateView()
    }
}
